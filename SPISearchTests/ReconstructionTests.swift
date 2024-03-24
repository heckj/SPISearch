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

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let results = try decoder.decode(LogArray.self, from: data)
        // dump(results)
        XCTAssertEqual(results.count, 181)
        let ordered_lines = results.sorted().map { logstruct in
            logstruct.line
        }

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

        var engine = ReconstructionEngine()

        for aLine in ordered_lines {
            if let result = try regexForSearchQuery.firstMatch(in: aLine) {
                print("JSON: \(result[jsonRef])")
                if let jsonAsData = String(result[jsonRef]).data(using: .utf8) {
                    let result = try decoder.decode(SearchResultQuery.self, from: jsonAsData)
                    // dump(result)
                    engine.addQuery(id: result.searchID, query: result)
                } else {
                    print("FAILED TO CONVERT JSON TO DATA")
                    XCTFail()
                }
            }

            if let result = try regexForSearchResultFragment.firstMatch(in: aLine) {
                // The index is only place that preserves the ordering of the results,
                // which can otherwise be linked through a search id (UUID)
                print("INDEX: \(result[indexRef])")
                print("JSON: \(result[jsonRef])")
                if let jsonAsData = String(result[jsonRef]).data(using: .utf8) {
                    let decoded = try decoder.decode(SearchResultFragment.self, from: jsonAsData)
                    engine.addFragment(id: decoded.searchID, index: result[indexRef], frag: decoded)
                    // dump(results)
                } else {
                    print("FAILED TO CONVERT JSON TO DATA")
                    XCTFail()
                }
            }
        }
        XCTAssertTrue(engine.issues().isEmpty)
    }
}

struct ReconstructionEngine {
    enum Problems {
        case extraQueryWithoutFragments(UUID)
        case fragmentsWithoutQuery(UUID)
    }

    var queries: [UUID: SearchResultQuery] = [:]
    var fragments: [UUID: [Int: SearchResultFragment]] = [:]

    func issues() -> [Problems] {
        let queryIds: Set<UUID> = Set(queries.keys)
        let fragementIds: Set<UUID> = Set(fragments.keys)
        var problems: [Problems] = []
        for extra_query in queryIds.subtracting(fragementIds) {
            problems.append(.extraQueryWithoutFragments(extra_query))
        }
        for extra_fragment in fragementIds.subtracting(queryIds) {
            problems.append(.extraQueryWithoutFragments(extra_fragment))
        }
        return problems
    }

    func searchIds() -> [UUID] {
        let queryIds: Set<UUID> = Set(queries.keys)
        let fragementIds: Set<UUID> = Set(fragments.keys)
        let combined = queryIds.union(fragementIds)
        return Array(combined)
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
