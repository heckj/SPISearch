import SPISearchResult
import XCTest

final class SearchMetricsTests: XCTestCase {
    let sample = SearchRank.exampleWithReviews()

    func basicMetrics() -> SearchMetrics? {
        let completeSearchResult = sample.searchResultCollection[1]
        if let medianValues = sample.medianRelevancyValues(for: completeSearchResult) {
            return SearchMetrics(searchResult: completeSearchResult, reviews: medianValues)
        }
        return nil
    }

    func basicMetricsOrderedOptimally() -> SearchMetrics? {
        let searchResult = sample.searchResultCollection[1]
        let reversedSearchResult = SearchResult(
            timestamp: searchResult.timestamp,
            query: searchResult.query,
            keywords: searchResult.keywords,
            authors: searchResult.authors,
            // this bit of hackery puts the "yorkie" result - with partial relevancy - as the final result
            packages: searchResult.packages.sorted(by: { lhs, rhs in
                lhs.id.owner < rhs.id.owner
            })
        )
        if let medianValues = sample.medianRelevancyValues(for: reversedSearchResult) {
            return SearchMetrics(searchResult: reversedSearchResult, reviews: medianValues)
        }
        return nil
    }

    func basicMetricsOrderedUnoptimally() -> SearchMetrics? {
        let searchResult = sample.searchResultCollection[1]
        let reversedSearchResult = SearchResult(
            timestamp: searchResult.timestamp,
            query: searchResult.query,
            keywords: searchResult.keywords,
            authors: searchResult.authors,
            // this bit of hackery puts the "yorkie" result - with partial relevancy - as the first result
            packages: searchResult.packages.sorted(by: { lhs, rhs in
                lhs.id.owner > rhs.id.owner
            })
        )
        if let medianValues = sample.medianRelevancyValues(for: reversedSearchResult) {
            return SearchMetrics(searchResult: reversedSearchResult, reviews: medianValues)
        }
        return nil
    }

    func testPrecision() throws {
        let metrics = basicMetrics()
        dump(sample.searchResultCollection[1])
        dump(sample.medianRelevancyValues(for: sample.searchResultCollection[1]))
        XCTAssertNotNil(metrics)
        XCTAssertEqual(try XCTUnwrap(metrics).precision, 0.9, accuracy: 0.001)
        // precision is independent of result ordering
        XCTAssertEqual(try XCTUnwrap(basicMetricsOrderedOptimally()).precision, 0.9, accuracy: 0.001)
    }

    func testRecall() throws {
        let metrics = basicMetrics()
        XCTAssertNotNil(metrics)
        XCTAssertEqual(try XCTUnwrap(metrics).recall, 0.9, accuracy: 0.001)
        // recall is independent of search result ordering
        XCTAssertEqual(try XCTUnwrap(basicMetricsOrderedOptimally()).recall, 0.9, accuracy: 0.001)
    }

    func testMeanReciprocalRankCalculation() throws {
        let metrics = basicMetrics()
        XCTAssertNotNil(metrics)
        XCTAssertEqual(try XCTUnwrap(metrics).meanReciprocalRank, 1.0, accuracy: 0.001)
        // reciprical rank is independent of search result ordering
        let reversedMetrics = basicMetricsOrderedOptimally()
        XCTAssertNotNil(reversedMetrics)
        XCTAssertEqual(try XCTUnwrap(reversedMetrics).meanReciprocalRank, 1.0, accuracy: 0.001)
    }

    func testNDCG() throws {
        let metrics = basicMetrics()
        XCTAssertNotNil(metrics)
        XCTAssertEqual(try XCTUnwrap(metrics).ndcg, 0.9794, accuracy: 0.001)
        // NDCG rank is NOT independent of search result ordering
        let optimalResults = basicMetricsOrderedOptimally()
        XCTAssertNotNil(optimalResults)
        XCTAssertEqual(try XCTUnwrap(optimalResults).ndcg, 1.0, accuracy: 0.001)

        let unoptimalResults = basicMetricsOrderedUnoptimally()
        XCTAssertNotNil(unoptimalResults)
        XCTAssertEqual(try XCTUnwrap(unoptimalResults).ndcg, 0.8887, accuracy: 0.001)
    }

    func testAdjustingMedianMetricsByAddingReview() throws {
        let completeSearchResult = sample.searchResultCollection[1]
        let unknownReviewer = UUID()

        var sampleCopy = sample // make copy to update

        sampleCopy.addOrUpdateRelevanceEvaluation(reviewer: unknownReviewer, query: "crdt", packageId: .init(owner: "heckj", repository: "CRDT"), relevance: .partial)

        let relevancyValues = sampleCopy.relevancyValues(for: completeSearchResult, by: unknownReviewer)
        XCTAssertNil(relevancyValues) // relevancy values *will not* be returned unless complete

        let medianValues = sampleCopy.medianRelevancyValues(for: completeSearchResult)
        XCTAssertNotNil(medianValues)
        XCTAssertEqual(medianValues?.relevanceValue[.init(owner: "heckj", repository: "CRDT")], 0.75)

        let metricsAdjustedByReview = try SearchMetrics(searchResult: completeSearchResult, reviews: XCTUnwrap(medianValues))
        XCTAssertNotNil(metricsAdjustedByReview)
        let verified = try XCTUnwrap(metricsAdjustedByReview)

        XCTAssertEqual(verified.precision, 0.85, accuracy: 0.001)
        XCTAssertEqual(verified.recall, 0.85, accuracy: 0.001)
        XCTAssertEqual(verified.meanReciprocalRank, 0.5, accuracy: 0.001)
        XCTAssertEqual(verified.ndcg, 0.9248, accuracy: 0.001)
    }
}
