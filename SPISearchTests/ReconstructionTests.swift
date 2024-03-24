import RegexBuilder
import SPISearch
import SPISearchResult
import XCTest

final class ReconstructionTests: XCTestCase {
    static let filename = "loki_export"

    func sampleData() throws -> Data {
        let testBundle = Bundle(for: type(of: self))
        guard let fileUrl = testBundle.url(forResource: ReconstructionTests.filename, withExtension: "json")
        else { fatalError() }
        return try Data(contentsOf: fileUrl)
    }

    typealias LogArray = [LokiLogExport]

    func testDecodingAPISearchResponse() async throws {
        let data = try sampleData()
        XCTAssertTrue(data.count > 0)

        var engine = ReconstructionEngine()
        try engine.loadData(data)

        XCTAssertTrue(try engine.issues().isEmpty)
    }
}

struct ReconstructionEngine {
    struct ParseJSONAsDataError: LocalizedError {
        let jsonString: String
        var errorDescription: String? {
            "Failed to convert JSONString \(jsonString) to data"
        }
    }
    struct ParseTimestampError: LocalizedError {
        let timestamp: String
        var errorDescription: String? {
            "Failed to convert timestamp \(timestamp) to date"
        }
    }
    struct FatalDiagnostic: LocalizedError {
        let msg: String
        var errorDescription: String? {
            "Fatal issue during diagnostics: \(msg)"
        }
    }

    enum Problems {
        case extraQueryWithoutFragments(UUID)
        case fragmentsWithoutQuery(UUID)
        case fragmentsDontStartZero(UUID)
        case missingFragment(UUID, Int)
        case missingTimestamp(UUID)
    }

    var timestamps: [UUID:Date] = [:]
    var queries: [UUID: SearchResultQuery] = [:]
    var fragments: [UUID: [Int: SearchResultFragment]] = [:]

    func issues() throws -> [Problems] {
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
            for i in minKey...maxKey {
                if fragmentDict[i] == nil {
                    problems.append(.missingFragment(key, i))
                }
            }
        }
        return problems
    }
    
    func searchResults() -> [SPISearchResult.SearchResult] {
        var results: [SearchResult] = []
        for searchId in fragments.keys {
            
            guard let query = queries[searchId]?.query,
                  let fragmentDict = fragments[searchId],
                  let dateForQuery = timestamps[searchId] else {
                break
            }
            var authors: [String] = []
            var keywords: [String] = []
            var packages: [SearchResult.Package] = []
            for indexPosition in fragmentDict.keys.sorted() {
                if let fragment: SearchResultFragment = fragmentDict[indexPosition] {
                    switch fragment.result {
                    case .author(let authorResult):
                        authors.append(authorResult.name)
                    case .keyword(let keywordResult):
                        keywords.append(keywordResult.keyword)
                    case .package(let packageResult):
                        let packageId: SearchResult.Package.PackageId = .init(owner: packageResult.repositoryOwner, repository: packageResult.repositoryName)
                        let srPackage = SearchResult.Package(
                            id: packageId,
                            name: packageResult.packageName,
                            package_keywords: packageResult.keywords ?? [],
                            summary: packageResult.summary,
                            stars: packageResult.stars ?? 0,
                            has_docs: packageResult.hasDocs,
                            last_activity: packageResult.lastActivityAt)
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
    

    func searchIds() -> [UUID] {
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
                let dateFromTimestamp = Date(timeIntervalSince1970: timeStampAsDouble)
                if let jsonAsData = String(result[jsonRef]).data(using: .utf8) {
                    let result = try decoder.decode(SearchResultQuery.self, from: jsonAsData)
                    self.addQuery(id: result.searchID, query: result)
                    self.setTimeStamp(id: result.searchID, dateFromTimestamp)
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
                    self.addFragment(id: decoded.searchID, index: result[indexRef], frag: decoded)
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
