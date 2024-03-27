import SPISearch
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

    func testReconstructingFromJSONExportAsData() async throws {
        let data = try sampleData()
        XCTAssertTrue(data.count > 0)

        var engine = ReconstructionEngine()
        try engine.loadData(data)

        XCTAssertTrue(try engine.issues().isEmpty)
    }
}
