//
//  SwiftMetricsTests.swift
//  SPISearchTests
//
//  Created by Joseph Heck on 7/6/22.
//

@testable import SPISearch
import XCTest

final class SwiftMetricsTests: XCTestCase {
    func testPrecisionCalculation() throws {
        let precision = SearchMetrics.calculatePrecision(searchResult: RecordedSearchResult.example, ranking: RelevanceRecord.example)
        XCTAssertEqual(precision, 1.0, accuracy: 0.001)
    }

    func testRecallCalculation() throws {
        let recall = SearchMetrics.calculateRecall(searchResult: RecordedSearchResult.example, ranking: RelevanceRecord.example)
        XCTAssertEqual(recall, 1.0, accuracy: 0.001)
    }
}
