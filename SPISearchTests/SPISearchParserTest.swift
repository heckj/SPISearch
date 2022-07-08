//
//  SPISearchParserTest.swift
//  SPISearchTests
//
//  Created by Joseph Heck on 7/8/22.
//

@testable import SPISearch
import XCTest

final class SPISearchParserTest: XCTestCase {
    var htmlSample = ""

    override func setUpWithError() throws {
        let testBundle = Bundle(for: type(of: self))
        if let resourceURL = testBundle.url(forResource: "bezier_query_8jul22", withExtension: "txt") {
            htmlSample = try String(contentsOf: resourceURL, encoding: .utf8)
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testResourceLoading() throws {
        XCTAssertFalse(htmlSample.isEmpty)
    }

    func testSearchParser() async throws {
        let searchResultSet = try await SPISearchParser.parse(htmlSample)
        XCTAssertNotNil(searchResultSet)
        XCTAssertEqual(searchResultSet.matched_keywords.count, 5)
        // verifying https://github.com/heckj/SPISearch/issues/15 is resolved
        XCTAssertEqual(searchResultSet.matched_keywords.sorted(),
                       ["bezier", "bezier-animation", "bezier-curve", "bezier-path", "uibezierpath"])
        XCTAssertEqual(searchResultSet.results.count, 6)
        XCTAssertEqual(searchResultSet.results[0].id, "pocketsvg/PocketSVG")
    }
}
