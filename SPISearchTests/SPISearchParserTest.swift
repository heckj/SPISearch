//
//  SPISearchParserTest.swift
//  SPISearchTests
//
//  Created by Joseph Heck on 7/8/22.
//

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

    func testExample() throws {
        XCTAssertFalse(htmlSample.isEmpty)
    }
}
