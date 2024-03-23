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
        let results = try decoder.decode(LogArray.self, from: data)
        // dump(results)
        XCTAssertEqual(results.count, 181)
        let ordered_lines = results.sorted().map { logstruct in
            logstruct.line
        }
        print(ordered_lines)
        // [ INFO ] SearchLogger: searchresult[0]: {"id":"5194EE2C-FF08-495E-AE8E-2A470BFFC777","r":{"author":{"_0":{"name":"Alamofire"}}}} [component: server]
    }
}
