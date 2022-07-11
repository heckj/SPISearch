//
//  SPISearchTests.swift
//  SPISearchTests
//
//  Created by Joseph Heck on 7/4/22.
//

@testable import SPISearch
import XCTest
final class SPISearchTests: XCTestCase {
    func testSearchURLAssemblyEmpty() throws {
        let result = SPISearchParser.assembleQueryURI("")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.query, "query=")
    }

    func testSearchURLAssemblyOneTerm() throws {
        let result = SPISearchParser.assembleQueryURI("ping")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.query, "query=ping")
    }

    func testSearchURLAssemblyMultiTerm() throws {
        let result = SPISearchParser.assembleQueryURI("ui bezier")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.query, "query=ui%20bezier")
    }

    func testIdentifierExtraction() throws {
        let ranking = SearchRank(RecordedSearchResult.example)
        XCTAssertEqual(ranking.identifiers.count, 6)

        XCTAssertEqual(SearchRank().identifiers.count, 0)
    }

    func testTermsFromRecordedSearchResult() throws {
        let terms = RecordedSearchResult.example.searchTerms
        // print(RecordedSearchResult.example.url.absoluteString)
        XCTAssertEqual(terms, "bezier")
    }

    func testingIndirectSearchTermRetrieval() throws {
        let model = SearchRank.extendedExample
        let terms = model.searchRanking.storedSearches.first?.searchTerms ?? ""
        XCTAssertNotNil(terms)
        XCTAssertEqual(terms, "bezier")
        // print("--\(terms)--")
    }
}
