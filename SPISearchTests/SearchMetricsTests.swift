//
//  SearchMetricsTests.swift
//  SPISearchTests
//
//  Created by Joseph Heck on 7/6/22.
//

@testable import SPISearch
import XCTest

final class SearchMetricsTests: XCTestCase {
    func testPrecisionCalculation() throws {
        let precision = SearchMetrics.calculatePrecision(searchResult: RecordedSearchResult.example, ranking: RelevanceRecord.example.computedValues())
        XCTAssertEqual(precision, 1.0, accuracy: 0.001)
    }

    func testRecallCalculation() throws {
        let recall = SearchMetrics.calculateRecall(searchResult: RecordedSearchResult.example, ranking: RelevanceRecord.example.computedValues())
        XCTAssertEqual(recall, 1.0, accuracy: 0.001)
    }

    func testMeanReciprocalRankCalculation() throws {
        let mrr = SearchMetrics.calculateMeanReciprocalRank(searchResult: RecordedSearchResult.example, ranking: RelevanceRecord.example.computedValues())
        XCTAssertEqual(mrr, 1, accuracy: 0.001)
    }

    func testInitializer() throws {
        let metrics = SearchMetrics(
            searchResult: RecordedSearchResult.example,
            ranking: RelevanceRecord.example.computedValues()
        )
        XCTAssertNotNil(metrics)
    }
}
