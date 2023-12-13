import CustomDump
import SPISearchResult
import XCTest

final class RelevancyScoreTests: XCTestCase {
    let sample = SearchRank.exampleWithReviews()

    func testRelevancyCompletionForSample() throws {
        let reviewerId = try XCTUnwrap(sample.reviewedEvaluationCollections.keys.first)

        XCTAssertFalse(sample.evaluationComplete(for: sample.searchResultCollection[0], for: reviewerId))
        XCTAssertEqual(sample.percentEvaluationComplete(for: sample.searchResultCollection[0], for: reviewerId), 0.833, accuracy: 0.01)

        XCTAssertTrue(sample.evaluationComplete(for: sample.searchResultCollection[1], for: reviewerId))
        XCTAssertEqual(sample.percentEvaluationComplete(for: sample.searchResultCollection[1], for: reviewerId), 1.0, accuracy: 0.01)

        XCTAssertFalse(sample.evaluationComplete(for: sample.searchResultCollection[2], for: reviewerId))
        XCTAssertEqual(sample.percentEvaluationComplete(for: sample.searchResultCollection[2], for: reviewerId), 0.0, accuracy: 0.01)
    }

    func testRelevancyValues() throws {
        let reviewerId = try XCTUnwrap(sample.reviewedEvaluationCollections.keys.first)
        let completeSearchResult = sample.searchResultCollection[1]
        XCTAssertTrue(sample.evaluationComplete(for: completeSearchResult, for: reviewerId))
        let relevancyValues = sample.relevancyValues(for: completeSearchResult, by: reviewerId)
        XCTAssertEqual(relevancyValues?.query_terms, "crdt")
        XCTAssertEqual(relevancyValues?.relevanceValue.count, 5)

        let medianValues = sample.medianRelevancyValues(for: completeSearchResult)
        XCTAssertEqual(medianValues?.query_terms, "crdt")
        XCTAssertEqual(medianValues?.relevanceValue.count, 5)
        XCTAssertEqual(medianValues?.relevanceValue[.init(owner: "heckj", repository: "CRDT")], 1.0)

        XCTAssertNoDifference(try XCTUnwrap(relevancyValues), try XCTUnwrap(medianValues))
        let unknownReviewer = UUID()
        XCTAssertNil(sample.relevancyValues(for: completeSearchResult, by: unknownReviewer))
    }

    func testMedianValueUpdateAfterAddingReview() throws {
        let completeSearchResult = sample.searchResultCollection[1]
        let unknownReviewer = UUID()

        var sampleCopy = sample // make copy to update

        sampleCopy.addOrUpdateRelevanceEvaluation(reviewer: unknownReviewer, query: "crdt", packageId: .init(owner: "heckj", repository: "CRDT"), relevance: .partial)

        let relevancyValues = sampleCopy.relevancyValues(for: completeSearchResult, by: unknownReviewer)
        XCTAssertNil(relevancyValues) // relevancy values *will not* be returned unless complete

        let medianValues = sampleCopy.medianRelevancyValues(for: completeSearchResult)
        XCTAssertNotNil(medianValues)
        XCTAssertEqual(medianValues?.relevanceValue[.init(owner: "heckj", repository: "CRDT")], 0.75)
    }
}
