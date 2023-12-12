//
//  SearchRankTests.swift
//  SPISearchTests
//
//  Created by Joseph Heck on 7/4/22.
//

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

        let reviewerId = UUID()
        let queue = searchrank.queueOfReviews(reviewerId: reviewerId)

        XCTAssertEqual(queue.count, 6)
        XCTAssertEqual(queue[0].query, "crdt")
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

        let reviewerId = UUID()
        let queue = searchrank.queueOfReviews(reviewerId: reviewerId)

        XCTAssertEqual(queue.count, 6)
        XCTAssertEqual(queue[0].query, "crdt")
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

        let reviewerId = UUID()
        let queue = searchrank.queueOfReviews(reviewerId: reviewerId)

        XCTAssertEqual(queue.count, 14)
        XCTAssertEqual(queue[0].query, "bezier")
        XCTAssertEqual(queue[8].query, "crdt")
    }

    func testAddEvaluator() throws {
        searchrank.searchResultCollection.append(SearchResult.exampleCollection[0])

        XCTAssertEqual(searchrank.reviewedEvaluationCollections.count, 0)
        XCTAssertEqual(searchrank.reviewerNames.count, 0)

        let reviewerId = UUID()
        let reviewName = "exampleReviewer"
        searchrank.addOrUpdateEvaluator(reviewerId: reviewerId, reviewerName: reviewName)

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
        searchrank.addOrUpdateEvaluator(reviewerId: reviewerId, reviewerName: reviewName)

        XCTAssertEqual(searchrank.reviewedEvaluationCollections.count, 0)
        XCTAssertEqual(searchrank.reviewerNames.count, 1)
        XCTAssertEqual(searchrank.reviewerNames[reviewerId], reviewName)

        // Add a relevance score for one of the packages in the first (and only) query
        searchrank.addOrUpdateRelevanceEvaluation(reviewer: reviewerId,
                                                  query: "crdt",
                                                  packageId: SearchResult.Package.PackageId(owner: "heckj", repository: "CRDT"),
                                                  relevance: .relevant)

        XCTAssertEqual(searchrank.reviewedEvaluationCollections.count, 1)

        let queue = searchrank.queueOfReviews(reviewerId: reviewerId)

        XCTAssertEqual(queue.count, 5)
        XCTAssertEqual(queue[0].query, "crdt")
    }

    func testExampleWithReviews() throws {
        let sample = SearchRank.exampleWithReviews()

        XCTAssertEqual(sample.reviewedEvaluationCollections.count, 1)
        let listOfReviewsByReviewer = try XCTUnwrap(sample.reviewedEvaluationCollections[XCTUnwrap(sample.reviewerNames.keys.first)])
        XCTAssertEqual(listOfReviewsByReviewer.count, 1)
        XCTAssertEqual(listOfReviewsByReviewer[0].reviews.count, 5)
    }

    func testReviewerName() throws {
        let sample = SearchRank.exampleWithReviews()
        XCTAssertEqual(sample.reviewerNames.count, 1)

        let reviewerIDs = sample.reviewerNames.keys
        XCTAssertEqual(reviewerIDs.count, 1)
        XCTAssertEqual(try sample.reviewerNames[XCTUnwrap(sample.reviewerNames.keys.first)], "Fred")
    }

    func testReviewNames() throws {
        let sample = SearchRank.exampleWithReviews()
        XCTAssertEqual(sample.reviewers.count, 1)
    }

    func testQueriesReviewed() throws {
        let sample = SearchRank.exampleWithReviews()
        let reviewerID = try XCTUnwrap(sample.reviewerNames.keys.first)
        XCTAssertEqual(sample.queriesReviewed(for: reviewerID), ["crdt"])
    }

    func testReviewsByIdForQuery() throws {
        let sample = SearchRank.exampleWithReviews()
        let reviewerID = try XCTUnwrap(sample.reviewerNames.keys.first)
        print(sample.reviews(for: reviewerID, query: "crdt"))
        XCTAssertEqual(sample.reviews(for: reviewerID, query: "crdt").count, 5)
    }
}
