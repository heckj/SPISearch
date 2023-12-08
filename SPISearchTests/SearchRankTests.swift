//
//  SearchRankTests.swift
//  SPISearchTests
//
//  Created by Joseph Heck on 7/4/22.
//

@testable import SPISearch
import SPISearchResult
import XCTest
final class SearchRankTests: XCTestCase {
    var searchrank: SearchRank = .init()

    override func setUpWithError() throws {
        searchrank = SearchRank()
    }

    func testDefaultAssumptions() throws {
        XCTAssertEqual(searchrank.reviewedEvaluationCollections.count, 0)
        XCTAssertEqual(searchrank.reviewerNames.count, 0)
        XCTAssertEqual(searchrank.searchResultCollection.count, 0)
    }

    func testEvalQueueRetrieval() throws {
        // add single search collection
        searchrank.searchResultCollection.append(SearchResult.exampleCollection[0])
        XCTAssertEqual(searchrank.searchResultCollection.count, 1)
        XCTAssertEqual(searchrank.searchResultCollection[0].packages.count, 6)
        XCTAssertEqual(searchrank.searchResultCollection[0].authors.count, 1)
        XCTAssertEqual(searchrank.searchResultCollection[0].keywords.count, 3)

        let reviewerId = UUID().uuidString
        let queue = searchrank.queueOfReviews(reviewerId: reviewerId)

        XCTAssertEqual(queue.count, 1)
        XCTAssertNotNil(queue["crdt"])

        let setOfPackagesToReview = try XCTUnwrap(queue["crdt"])
        XCTAssertEqual(setOfPackagesToReview.count, 6)
    }

    func testEvalQueueRetrievalWithSameTwoQueriesAndDifferentResults() throws {
        // add single search collection
        searchrank.searchResultCollection.append(SearchResult.exampleCollection[0])
        searchrank.searchResultCollection.append(SearchResult.exampleCollection[1])
        XCTAssertEqual(searchrank.searchResultCollection.count, 2)

        XCTAssertEqual(searchrank.searchResultCollection[0].packages.count, 6)
        XCTAssertEqual(searchrank.searchResultCollection[0].authors.count, 1)
        XCTAssertEqual(searchrank.searchResultCollection[0].keywords.count, 3)

        XCTAssertEqual(searchrank.searchResultCollection[1].packages.count, 5)
        XCTAssertEqual(searchrank.searchResultCollection[1].authors.count, 1)
        XCTAssertEqual(searchrank.searchResultCollection[1].keywords.count, 3)

        let reviewerId = UUID().uuidString
        let queue = searchrank.queueOfReviews(reviewerId: reviewerId)

        XCTAssertEqual(queue.count, 1)
        XCTAssertNotNil(queue["crdt"])

        let setOfPackagesToReview = try XCTUnwrap(queue["crdt"])
        XCTAssertEqual(setOfPackagesToReview.count, 6)
    }

    func testEvalQueueRetrievalWithTwoDifferentQueries() throws {
        // add single search collection
        searchrank.searchResultCollection.append(SearchResult.exampleCollection[0])
        searchrank.searchResultCollection.append(SearchResult.exampleCollection[1])
        searchrank.searchResultCollection.append(SearchResult.exampleCollection[2])
        XCTAssertEqual(searchrank.searchResultCollection.count, 3)

        XCTAssertEqual(searchrank.searchResultCollection[0].packages.count, 6)
        XCTAssertEqual(searchrank.searchResultCollection[0].authors.count, 1)
        XCTAssertEqual(searchrank.searchResultCollection[0].keywords.count, 3)

        XCTAssertEqual(searchrank.searchResultCollection[1].packages.count, 5)
        XCTAssertEqual(searchrank.searchResultCollection[1].authors.count, 1)
        XCTAssertEqual(searchrank.searchResultCollection[1].keywords.count, 3)

        XCTAssertEqual(searchrank.searchResultCollection[2].packages.count, 8)
        XCTAssertEqual(searchrank.searchResultCollection[2].authors.count, 0)
        XCTAssertEqual(searchrank.searchResultCollection[2].keywords.count, 5)

        let reviewerId = UUID().uuidString
        let queue = searchrank.queueOfReviews(reviewerId: reviewerId)

        XCTAssertEqual(queue.count, 2)
        XCTAssertNotNil(queue["crdt"])
        XCTAssertNotNil(queue["bezier"])

        let setOfCRDTPackagesToReview = try XCTUnwrap(queue["crdt"])
        XCTAssertEqual(setOfCRDTPackagesToReview.count, 6)

        let setOfBezierPackagesToReview = try XCTUnwrap(queue["bezier"])
        XCTAssertEqual(setOfBezierPackagesToReview.count, 8)
    }

    func testAddEvaluator() throws {
        searchrank.searchResultCollection.append(SearchResult.exampleCollection[0])

        XCTAssertEqual(searchrank.reviewedEvaluationCollections.count, 0)
        XCTAssertEqual(searchrank.reviewerNames.count, 0)

        let reviewerId = UUID()
        let reviewName = "exampleReviewer"
        searchrank.addOrUpdateEvaluator(reviewerId: reviewerId.uuidString, reviewerName: reviewName)

        XCTAssertEqual(searchrank.reviewedEvaluationCollections.count, 0)
        XCTAssertEqual(searchrank.reviewerNames.count, 1)
        XCTAssertEqual(searchrank.reviewerNames[reviewerId], reviewName)
    }

    func testAddEvaluation() throws {
        searchrank.searchResultCollection.append(SearchResult.exampleCollection[0])
        XCTAssertEqual(searchrank.reviewedEvaluationCollections.count, 0)
        XCTAssertEqual(searchrank.reviewerNames.count, 0)

        let reviewerId = UUID()
        let reviewName = "exampleReviewer"
        searchrank.addOrUpdateEvaluator(reviewerId: reviewerId.uuidString, reviewerName: reviewName)

        XCTAssertEqual(searchrank.reviewedEvaluationCollections.count, 0)
        XCTAssertEqual(searchrank.reviewerNames.count, 1)
        XCTAssertEqual(searchrank.reviewerNames[reviewerId], reviewName)

        // Add a relevance score for one of the packages in the first (and only) query
        searchrank.addOrUpdateRelevanceEvaluation(reviewer: reviewerId,
                                                  query: "crdt",
                                                  packageId: SearchResult.Package.PackageId(owner: "heckj", repository: "CRDT"),
                                                  relevance: .relevant)

        XCTAssertEqual(searchrank.reviewedEvaluationCollections.count, 1)

        let queue = searchrank.queueOfReviews(reviewerId: reviewerId.uuidString)

        XCTAssertEqual(queue.count, 1)
        XCTAssertNotNil(queue["crdt"])

        let setOfCRDTPackagesToReview = try XCTUnwrap(queue["crdt"])
        XCTAssertEqual(setOfCRDTPackagesToReview.count, 5)
    }
}
