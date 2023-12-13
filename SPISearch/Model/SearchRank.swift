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
struct SearchRank: Identifiable, Hashable, Codable {
    var id = UUID()

    typealias ReviewerID = UUID

    var searchResultCollection: [SearchResult] = []
    var reviewedEvaluationCollections: [ReviewerID: [ReviewSet]] = [:]
    var reviewerNames: [ReviewerID: String]

    var reviewers: [ReviewerID] {
        reviewedEvaluationCollections.keys.sorted { lhs, rhs in
            // reconsider this into a lookup of the reviewer Id's name
            lhs.uuidString < rhs.uuidString
        }
    }

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

    // REVIEW ACCESSORS

    func nameOfReviewer(reviewerId: UUID) -> String {
        if let name = reviewerNames[reviewerId] {
            return name
        } else {
            return "unknown"
        }
    }

    func queriesReviewed(for reviewer: UUID) -> [String] {
        if let collection = reviewedEvaluationCollections[reviewer] {
            let queries = collection.reduce(into: Set<String>()) { partialResult, reviewSet in
                partialResult.insert(reviewSet.query_terms)
            }
            return queries.sorted()
        }
        return []
    }

    func reviews(for reviewer: UUID, query: String) -> [(SearchResult.Package.PackageId, Relevance)] {
        var listToReturn: [(SearchResult.Package.PackageId, Relevance)] = []
        if let collection = reviewedEvaluationCollections[reviewer],
           let reviewset = collection.first(where: { reviewSet in
               reviewSet.query_terms == query
           })
        {
            for key in reviewset.reviews.keys.sorted() {
                if let relevance = reviewset.reviews[key] {
                    listToReturn.append((key, relevance))
                }
            }
        }
        return listToReturn
    }

    // UPDATING EVALUATIONS

    mutating func addOrUpdateEvaluator(reviewerId: UUID, reviewerName: String) {
        reviewerNames[reviewerId] = reviewerName
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

    func queueOfReviews(reviewerId: UUID) -> [PackageToEvaluate] {
        var packagesToReview: [String: Set<SearchResult.Package>] = [:]
        var matched_keywords: [String: [String]] = [:]
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
                if let existingReviewSet = reviewedEvaluationCollections[reviewerId]?.first(where: { reviewset in
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

    func percentEvaluationComplete(for searchResult: SearchResult, for reviewer: ReviewerID) -> Double {
        if let reviewsFromReviewer = reviewedEvaluationCollections[reviewer],
           let reviewSetToCheck = reviewsFromReviewer.first(where: { reviewSet in
               reviewSet.query_terms == searchResult.query
           })
        {
            let countComplete = searchResult.packages.reduce(into: 0) { partialResult, package in
                if reviewSetToCheck.reviews.keys.contains(package.id) {
                    partialResult = partialResult + 1
                }
            }
            return Double(countComplete) / Double(searchResult.packages.count)
        }
        return 0
    }

    func evaluationComplete(for searchResult: SearchResult, for reviewer: ReviewerID) -> Bool {
        if let reviewsFromReviewer = reviewedEvaluationCollections[reviewer],
           let reviewSetToCheck = reviewsFromReviewer.first(where: { reviewSet in
               reviewSet.query_terms == searchResult.query
           })
        {
            let completelyEvaluated = searchResult.packages.allSatisfy { package in
                reviewSetToCheck.reviews.keys.contains(package.id)
            }
            return completelyEvaluated
        }
        return false
    }

    func evaluationGloballyComplete(for searchResult: SearchResult) -> Bool {
        // grabs all the reviewSets (from all reviewers) where the query terms match the searchresult
        let setsToCheck = reviewedEvaluationCollections.flatMap { (_: ReviewerID, reviewSets: [ReviewSet]) in
            reviewSets.filter { set in
                set.query_terms == searchResult.query
            }
        }
        let complete = searchResult.packages.allSatisfy { pkg in
            let relevanceMarkers = setsToCheck.compactMap { set in
                set.reviews[pkg.id]
            }
            if relevanceMarkers.isEmpty {
                return false
            } else {
                return true
            }
        }
        return complete
    }

    func medianRelevancyValues(for searchResult: SearchResult) -> RelevancyValues? {
        var values = RelevancyValues(query_terms: searchResult.query, relevanceValue: [:])
        let setsToCheck = reviewedEvaluationCollections.flatMap { (_: ReviewerID, reviewSets: [ReviewSet]) in
            reviewSets.filter { set in
                set.query_terms == searchResult.query
            }
        }
        if setsToCheck.isEmpty {
            // no evaluations exist
            return nil
        }

        for pkg in searchResult.packages {
            let listOfRelevance = setsToCheck.compactMap { reviewSet in
                // print("checking \(reviewSet) (q: \(reviewSet.query_terms) - pkg: \(pkg.id) is  \(reviewSet.reviews[pkg.id])")
                reviewSet.reviews[pkg.id]
            }
            if listOfRelevance.isEmpty {
                // no evaluations exist
                return nil
            } else {
                let sum = listOfRelevance.reduce(into: 0.0) { partialResult, relevance in
                    partialResult += relevance.relevanceValue()
                }
                let avg = sum / Double(listOfRelevance.count)
                values.relevanceValue[pkg.id] = avg
            }
        }
        return values
    }

    func relevancyValues(for searchResult: SearchResult, by reviewer: ReviewerID) -> RelevancyValues? {
        var values = RelevancyValues(query_terms: searchResult.query, relevanceValue: [:])
        guard let reviewSet = reviewedEvaluationCollections[reviewer]?.first(where: { set in
            set.query_terms == searchResult.query
        }) else {
            return nil
        }
        for pkg in searchResult.packages {
            if let valueOfEval = reviewSet.reviews[pkg.id] {
                values.relevanceValue[pkg.id] = valueOfEval.relevanceValue()
            } else {
                // no review recorded, set it to a 0 value, meaning assumed irrelevant
                // values.relevanceValue[pkg.id] = 0.0
                // or maybe return nil, since we can't make a complete set of relevancy values?
                return nil
            }
        }
        return values
    }
}
