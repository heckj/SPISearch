//
//  RelevanceTests.swift
//  SPISearchTests
//
//  Created by Joseph Heck on 12/1/23.
//

@testable import SPISearch
import XCTest

final class RelevanceTests: XCTestCase {

    func testRelevanceValues() throws {
        XCTAssertEqual(
            Relevance.unknown.relevanceValue(), 0.0, accuracy:0.01)
        XCTAssertEqual(
            Relevance.not.relevanceValue(), 0.0, accuracy:0.01)
        XCTAssertEqual(
            Relevance.partial.relevanceValue(), 0.5, accuracy:0.01)
        XCTAssertEqual(
            Relevance.relevant.relevanceValue(), 1.0, accuracy:0.01)
    }

    func testBinaryRelevanceValues() throws {
        XCTAssertEqual(
            Relevance.unknown.relevanceValue(binary: true), 0.0, accuracy:0.01)
        XCTAssertEqual(
            Relevance.not.relevanceValue(binary: true), 0.0, accuracy:0.01)
        XCTAssertEqual(
            Relevance.partial.relevanceValue(binary: true), 1.0, accuracy:0.01)
        XCTAssertEqual(
            Relevance.relevant.relevanceValue(binary: true), 1.0, accuracy:0.01)
    }

}
