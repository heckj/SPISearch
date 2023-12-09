//
//  SearchRank.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import Foundation
import SPISearchResult
import SwiftUI

// A model that combines collections of searches and the evaluations of those search results
// by evaluators.
/// The SPISearch data model that encodes searches and ranked relevance reviews for those searches.
///
/// The core data model behind a SearchRank document, it stores search results from Swift Package Index.
/// The model represents the search results for a single set of query terms.
///
/// Every basic document should include at least `1` search result set. More searches can be stored, but
/// are expected to have the same set of query terms. The model can then have `0` or more relevance sets,
/// which are individual relevance assertions by people reviewing the results. A "complete" relevance sets should
/// cover all of the search results for all stored searches.
///
/// Any search, when combined with a relevance review set, should be able to provide specific metrics about the search results.
struct SearchRank: Identifiable, Codable {
    var id = UUID()

    typealias ReviewerID = UUID

    var searchResultCollection: [SearchResult] = []
    var reviewedEvaluationCollections: [ReviewerID: [ReviewSet]] = [:]
    var reviewerNames: [ReviewerID: String]

    // specifically for SwiftUI consumption - constructed random-access stuff
    // lexically sorted by reviewer "id" - the uuidString
    var sortedEvaluations: [(ReviewerID, [ReviewSet])] {
        var output: [(ReviewerID, [ReviewSet])] = []
        let sortedReviewers = reviewedEvaluationCollections.keys.sorted { lhs, rhs in
            // reconsider this into a lookup of the reviewer Id's name
            lhs.uuidString < rhs.uuidString
        }

        for reviewer in sortedReviewers {
            if let evalset = reviewedEvaluationCollections[reviewer] {
                output.append((reviewer, evalset))
            }
        }

        return output
    }

    init(id: UUID = UUID(), _ result: [SearchResult] = []) {
        self.id = id
        searchResultCollection = result
        reviewerNames = [:]
    }

    mutating func addOrUpdateEvaluator(reviewerId: String, reviewerName: String) {
        guard let properId = UUID(uuidString: reviewerId) else {
            return
        }
        reviewerNames[properId] = reviewerName
    }

    mutating func addOrUpdateRelevanceEvaluation(reviewer: UUID, query: String, packageId: SearchResult.Package.PackageId, relevance: Relevance) {
        if let reviewSets = reviewedEvaluationCollections[reviewer] {
            if let set = reviewSets.first(where: { reviewSet in
                reviewSet.query_terms == query
            }) {
                set.reviews[packageId] = relevance
            } else {
                // no review sets exist that match this query
                reviewedEvaluationCollections[reviewer]?.append(ReviewSet(query_terms: query, reviews: [packageId: relevance]))
            }
        } else {
            // no reviewSets for the reviewer
            reviewedEvaluationCollections[reviewer] = [ReviewSet(query_terms: query, reviews: [packageId: relevance])]
        }
    }

    func queueOfReviews(reviewerId: String) -> [PackageToEvaluate] {
        var packagesToReview: [String: Set<SearchResult.Package>] = [:]
        var matched_keywords: [String: [String]] = [:]
        guard let properId = UUID(uuidString: reviewerId) else {
            return []
        }
        // build a collection of all the possible summary -> packageId combinations to possibly
        // review
        for search in searchResultCollection {
            let packages = search.packages
            // create the empty set for this query, if it doesn't already exist
            if packagesToReview[search.query] == nil {
                packagesToReview[search.query] = Set<SearchResult.Package>()
                matched_keywords[search.query] = search.keywords
            }
            // iterating through the packages listed in this query to potentially add them
            for pkg in packages {
                // FILTERING - check to see if THIS reviewer has evaluations already recorded
                // for this query
                if let existingReviewSet = reviewedEvaluationCollections[properId]?.first(where: { reviewset in
                    reviewset.query_terms == search.query
                }) {
                    // If they do, then check to see if the package is already included in those
                    // evaluations. If it is, skip it. If it isn't, add it to the list of packages
                    // to review.
                    if existingReviewSet.reviews[pkg.id] == nil {
                        // there's not already a review by this person,
                        packagesToReview[search.query]?.insert(pkg)
                    }
                } else {
                    // no reviews yet by this reviewer, so add the package for review
                    packagesToReview[search.query]?.insert(pkg)
                }
            }
        }

        var finalQueue: [PackageToEvaluate] = []
        for query in packagesToReview.keys.sorted() {
            for pkg in packagesToReview[query] ?? [] {
                finalQueue.append(PackageToEvaluate(query: query, keywords: matched_keywords[query] ?? [], package: pkg))
            }
        }

        return finalQueue
    }

    //    var medianRelevancyRanking: ComputedRelevancyValues? {
    //        if relevanceSets.isEmpty {
    //            return nil
    //        }
    //        var medianRecord = ComputedRelevancyValues()
    //
    //        // retrieve a list of matched keywords from all the relevance sets
    //        // and toss them into a Set to de-duplicate them.
    //        let all_keywords = Set<String>(relevanceSets.flatMap { record in
    //            record.keywords.ratings.keys
    //        })
    //
    //        // Iterate through the set of all keywords and compute a median relevancy value
    //        for keyword in all_keywords {
    //            // this grabs and returns a list of relevancy enumerations where
    //            // the value isn't `.unknown`
    //
    //            let listOfRelevance = relevanceSets.compactMap { record -> Relevance? in
    //                let foundRelevance = record.keywords[keyword]
    //                if foundRelevance != .unknown { return foundRelevance }
    //                return nil
    //            }
    //            // We then convert those enumerated instances into valuation
    //            // numbers, sum them up, and divide by the number of relevancy
    //            // values found (again, not counting the "unknown" ones.
    //            let medianValue = listOfRelevance
    //                .map { $0.relevanceValue() }
    //                .reduce(into: 0) { partialResult, relValue in
    //                    partialResult += relValue
    //                } / Double(listOfRelevance.count)
    //            // No known relevancy options will result in a count of 0, and /0 == .nan
    //            // So don't include the keyword in the results.
    //            if !medianValue.isNaN {
    //                // Apply back into the return set.
    //                medianRecord.keywords[keyword] = medianValue
    //            }
    //        }
    //
    //        // retrieve a list of matched package identifiers from all the relevance sets
    //        // and toss them into a Set to de-duplicate them.
    //        let all_package_identifiers = Set<String>(relevanceSets.flatMap { record in
    //            record.packages.ratings.keys
    //        })
    //
    //        // Iterate through the set of all keywords and compute a median relevancy value
    //        for pkgId in all_package_identifiers {
    //            // this grabs and returns a list of relevancy enumerations where
    //            // the value isn't `.unknown`
    //            let listOfRelevance = relevanceSets.compactMap { record -> Relevance? in
    //                let foundRelevance = record.packages[pkgId]
    //                if foundRelevance != .unknown { return foundRelevance }
    //                return nil
    //            }
    //            // We then convert those enumerated instances into valuation
    //            // numbers, sum them up, and divide by the number of relevancy
    //            // values found (again, not counting the "unknown" ones.
    //            let medianValue = listOfRelevance
    //                .map { $0.relevanceValue() }
    //                .reduce(into: 0) { partialResult, relValue in
    //                    partialResult += relValue
    //                } / Double(listOfRelevance.count)
    //            // No known relevancy options will result in a count of 0, and /0 == .nan
    //            // So don't include the keyword in the results.
    //            if !medianValue.isNaN {
    //                // Apply back into the return set.
    //                medianRecord.packages[pkgId] = medianValue
    //            }
    //        }
    //
    //        // IMPL
    //        return medianRecord
    //    }
}
