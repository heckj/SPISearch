import Foundation
import RegexBuilder
import SPISearchResult
import OSLog


// loki JSON export snippet:
// {"line":"[ INFO ] SearchLogger: search: {\"query\":\"alamo\",\"searchID\":\"5194EE2C-FF08-495E-AE8E-2A470BFFC777\"} [component: server]\n","timestamp":"1707119454282289170","fields":{"component":"server","filename":"/var/log/f656468e522e9184b4342d740bcf1ad4b43cb831e527246a30ce1e30b71c0b73/f656468e522e9184b4342d740bcf1ad4b43cb831e527246a30ce1e30b71c0b73-json.log","job":"containers","stream":"stdout"}}
// What's the timestamp: UnixNS

//Unix: 1562708916 or with fractions 1562708916.000000123
//UnixMs: 1562708916414
//UnixUs: 1562708916414123
//UnixNs: 1562708916000000123
//        1707119454282289170

public struct ReconstructionEngine {
    public struct ParseJSONAsDataError: LocalizedError {
        let jsonString: String
        public var errorDescription: String? {
            "Failed to convert JSONString \(jsonString) to data"
        }
    }

    public struct ParseTimestampError: LocalizedError {
        let timestamp: String
        public var errorDescription: String? {
            "Failed to convert timestamp \(timestamp) to date"
        }
    }

    public struct FatalDiagnostic: LocalizedError {
        let msg: String
        public var errorDescription: String? {
            "Fatal issue during diagnostics: \(msg)"
        }
    }

    public enum Problems: CustomStringConvertible {
        public var description: String {
            switch self {
            case .extraQueryWithoutFragments(let uuid):
                "Extra query (\(uuid.uuidString)) reported without associated fragments"
            case .fragmentsWithoutQuery(let uuid):
                "Extra fragement (\(uuid.uuidString)) reported without an associated query"
            case .fragmentsDontStartZero(let uuid):
                "Possibly missing fragment for query (\(uuid.uuidString)) the reported fragments dont start at 0"
            case .missingFragment(let uuid, let intValue):
                "Missing fragement at index \(intValue) for query (\(uuid.uuidString))"
            case .missingTimestamp(let uuid):
                "Query (\(uuid.uuidString)) is missing a timestamp"
            }
        }
        
        case extraQueryWithoutFragments(UUID)
        case fragmentsWithoutQuery(UUID)
        case fragmentsDontStartZero(UUID)
        case missingFragment(UUID, Int)
        case missingTimestamp(UUID)
    }

    static func bestEffort(from fileURL: URL) throws -> [SearchResult] {
        var engine = ReconstructionEngine()
        var searchResults: [SearchResult] = []
        // The fileURL provided is a security scoped resource - so we need to request
        // (synchronous) access before we can use it. It's the stuff returned from
        // the .fileImporter() view modifier in SwiftUI
        let gotAccess = fileURL.startAccessingSecurityScopedResource()
        if !gotAccess { throw ImportError.fileAccessError(url: fileURL) }

        do {
            let data = try Data(contentsOf: fileURL)
            try engine.loadData(data)
            for importIssue in  try engine.issues() {
                Logger.app.warning("Import problem: \(importIssue)")
            }
            searchResults.append(contentsOf: engine.searchResults())
        } catch {
            Logger.app.error("Import Error: \(error.localizedDescription)")
        }
        
        // release access to the file
        fileURL.stopAccessingSecurityScopedResource()
        return searchResults
    }
    
    var timestamps: [UUID: Date] = [:]
    var queries: [UUID: SearchResultQuery] = [:]
    var fragments: [UUID: [Int: SearchResultFragment]] = [:]
    
    public init() {}

    public func issues() throws -> [Problems] {
        let queryIds: Set<UUID> = Set(queries.keys)
        let fragementIds: Set<UUID> = Set(fragments.keys)
        var problems: [Problems] = []
        for extra_query in queryIds.subtracting(fragementIds) {
            problems.append(.extraQueryWithoutFragments(extra_query))
        }
        for extra_fragment in fragementIds.subtracting(queryIds) {
            problems.append(.extraQueryWithoutFragments(extra_fragment))
        }
        for key in fragments.keys {
            if timestamps[key] == nil {
                problems.append(.missingTimestamp(key))
            }
            guard let fragmentDict = fragments[key] else {
                throw FatalDiagnostic(msg: "fragment key \(key) without any search result fragments")
            }
            guard let minKey = fragmentDict.keys.min(), let maxKey = fragmentDict.keys.max()
            else {
                throw FatalDiagnostic(msg: "Unable to find a min or max index in search fragments for query: \(key)")
            }
            if minKey > 0 {
                problems.append(.fragmentsDontStartZero(key))
            }
            // verify contiguous keys
            for i in minKey ... maxKey {
                if fragmentDict[i] == nil {
                    problems.append(.missingFragment(key, i))
                }
            }
        }
        return problems
    }

    public func searchResults() -> [SPISearchResult.SearchResult] {
        var results: [SearchResult] = []
        for searchId in fragments.keys {
            guard let query = queries[searchId]?.query,
                  let fragmentDict = fragments[searchId],
                  let dateForQuery = timestamps[searchId]
            else {
                break
            }
            var authors: [String] = []
            var keywords: [String] = []
            var packages: [SearchResult.Package] = []
            for indexPosition in fragmentDict.keys.sorted() {
                if let fragment: SearchResultFragment = fragmentDict[indexPosition] {
                    switch fragment.result {
                    case let .author(authorResult):
                        authors.append(authorResult.name)
                    case let .keyword(keywordResult):
                        keywords.append(keywordResult.keyword)
                    case let .package(packageResult):
                        let packageId: SearchResult.Package.PackageId = .init(owner: packageResult.repositoryOwner, repository: packageResult.repositoryName)
                        let srPackage = SearchResult.Package(
                            id: packageId,
                            name: packageResult.packageName,
                            package_keywords: packageResult.keywords ?? [],
                            summary: packageResult.summary,
                            stars: packageResult.stars ?? 0,
                            has_docs: packageResult.hasDocs,
                            last_activity: packageResult.lastActivityAt
                        )
                        packages.append(srPackage)
                    case .none:
                        break
                    }
                }
            }

            let newResult = SearchResult(timestamp: dateForQuery, query: query, keywords: keywords, authors: authors, packages: packages)
            results.append(newResult)
        }
        return results
    }

    public func searchIds() -> [UUID] {
        let queryIds: Set<UUID> = Set(queries.keys)
        let fragementIds: Set<UUID> = Set(fragments.keys)
        let combined = queryIds.union(fragementIds)
        return Array(combined)
    }

    typealias LogArray = [LokiLogExport]

    public mutating func loadData(_ data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let results = try decoder.decode(LogArray.self, from: data)
        let ordered_logs = results.sorted()

        let indexRef = Reference(Int.self)
        let jsonRef = Reference(Substring.self)

        let regexForSearchResultFragment = Regex {
            "[ INFO ] SearchLogger: searchresult["
            Capture(as: indexRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)!
            }
            "]: "
            Capture(as: jsonRef) {
                OneOrMore(.anyGraphemeCluster)
            }
            " [component: server]"
        }

        let regexForSearchQuery = Regex {
            "[ INFO ] SearchLogger: search: "
            Capture(as: jsonRef) {
                OneOrMore(.anyGraphemeCluster)
            }
            " [component: server]"
        }

        for logStruct in ordered_logs {
            if let result = try regexForSearchQuery.firstMatch(in: logStruct.line) {
                print("JSON: \(result[jsonRef])")
                guard let timeStampAsDouble = Double(logStruct.timestamp) else {
                    throw ParseTimestampError(timestamp: logStruct.timestamp)
                }
                let dateFromTimestamp = Date(timeIntervalSince1970: timeStampAsDouble / 1_000_000_000.0)
                if let jsonAsData = String(result[jsonRef]).data(using: .utf8) {
                    let result = try decoder.decode(SearchResultQuery.self, from: jsonAsData)
                    addQuery(id: result.searchID, query: result)
                    setTimeStamp(id: result.searchID, dateFromTimestamp)
                } else {
                    throw ParseJSONAsDataError(jsonString: String(result[jsonRef]))
                }
            }

            if let result = try regexForSearchResultFragment.firstMatch(in: logStruct.line) {
                // The index is only place that preserves the ordering of the results,
                // which can otherwise be linked through a search id (UUID)
                print("INDEX: \(result[indexRef])")
                print("JSON: \(result[jsonRef])")
                if let jsonAsData = String(result[jsonRef]).data(using: .utf8) {
                    let decoded = try decoder.decode(SearchResultFragment.self, from: jsonAsData)
                    addFragment(id: decoded.searchID, index: result[indexRef], frag: decoded)
                } else {
                    throw ParseJSONAsDataError(jsonString: String(result[jsonRef]))
                }
            }
        }
    }

    mutating func setTimeStamp(id: UUID, _ date: Date) {
        timestamps[id] = date
    }

    mutating func addFragment(id: UUID, index: Int, frag: SearchResultFragment) {
        if var fragForId = fragments[id] {
            fragForId[index] = frag
            fragments[id] = fragForId
        } else {
            fragments[id] = [index: frag]
        }
    }

    mutating func addQuery(id: UUID, query: SearchResultQuery) {
        queries[id] = query
    }
}
