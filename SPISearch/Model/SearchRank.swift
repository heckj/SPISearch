import Foundation
import SPISearchResult
import SwiftUI

/// The SPISearch data model that encodes collections of searches and relevance evaluation of the results in for those searches.
///
/// SearchRank is the core data model that makes up a SearchRank document.
/// In addition to storing the search results in a primarily read-only format, it stores information about relevancy reviewers and the evaluations to provide a relevance score for the searches.
///
/// Search relevancy evaluations are stored based first on the search query terms, and secondarily on the packages returned by searches.
/// When all of the packages in a search have a reviewed relevancy, the model provides relevancy values, which - with the search result - can provide search metrics.
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

    /// Creates a new SearchRank model
    /// - Parameters:
    ///   - id: A unique identifier for this model, defaults to a random UUID.
    ///   - result: A collection of search results with which to initialize the model.
    init(id: UUID = UUID(), _ result: [SearchResult] = []) {
        self.id = id
        searchResultCollection = result
        reviewerNames = [:]
    }

    // REVIEW ACCESSORS

    /// Returns the name of the reviewer as stored in the model for the identifier you provide.
    /// - Parameter reviewerId: The id of the reviewer.
    /// - Returns: The name of the reviewer, or "unknown" if the reviewer ID doesn't have a value recorded.
    func nameOfReviewer(reviewerId: UUID) -> String {
        if let name = reviewerNames[reviewerId] {
            return name
        } else {
            return "unknown"
        }
    }

    /// Returns a collection of the search query terms that the reviewer has, at least partially, evaluated.
    /// - Parameter reviewer: The id of the reviewer.
    func queriesReviewed(by reviewer: UUID) -> [String] {
        if let collection = reviewedEvaluationCollections[reviewer] {
            let queries = collection.reduce(into: Set<String>()) { partialResult, reviewSet in
                partialResult.insert(reviewSet.query_terms)
            }
            return queries.sorted()
        }
        return []
    }

    /// Returns a collection of the package relevancies for the query string and reviewer identity that you provide.
    /// - Parameters:
    ///   - reviewer: The id of the reviewer.
    ///   - query: The search query string.
    func reviews(by reviewer: UUID, query: String) -> [(SearchResult.Package.PackageId, Relevance)] {
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

    mutating func removeReview(by reviewer: UUID, query: String, id: SearchResult.Package.PackageId) {
        if let collection = reviewedEvaluationCollections[reviewer],
           let reviewset = collection.first(where: { reviewSet in
               reviewSet.query_terms == query
           })
        {
            reviewset.reviews.removeValue(forKey: id)
        }
    }

    // UPDATING EVALUATIONS

    /// Adds or updates the name of the reviewer for the reviewer id you provide.
    /// - Parameters:
    ///   - reviewerId: The id of the reviewer.
    ///   - reviewerName: The name of the reviewer.
    mutating func addOrUpdateEvaluator(reviewerId: UUID, reviewerName: String) {
        reviewerNames[reviewerId] = reviewerName
    }

    /// Updates the SearchRank model to store a relevancy evaluation.
    /// - Parameters:
    ///   - reviewer: The id of the reviewer.
    ///   - query: The search query being reviewed.
    ///   - packageId: The package being reviewed.
    ///   - relevance: The relevancy value of the package for the search query.
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

    /// Returns a collection of packages to evaluate from the searches stored in the model.
    /// - Parameter reviewerId: The id of the reviewer
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

    // EVALUATION COMPLETENESS

    /// Returns a percentage complete for the relevancy of packages for a search result by a reviewer
    /// - Parameters:
    ///   - searchResult: The search result
    ///   - reviewer: The id of the reviewer
    /// - Returns: A percentage value (0.0 ... 1.0)
    func percentEvaluationComplete(for searchResult: SearchResult, by reviewer: ReviewerID) -> Double {
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

    /// Returns a Boolean value that indicates whether the search result is fully evaluated by a single reviewer.
    /// - Parameters:
    ///   - searchResult: The search result.
    ///   - reviewer: The id of the reviewer.
    func evaluationComplete(for searchResult: SearchResult, by reviewer: ReviewerID) -> Bool {
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

    /// Returns a Boolean value that indicates whether the search result is fully evaluated across all reviewers.
    /// - Parameter searchResult: The search result.
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

    // METRICS COLLECTION

    /// Returns the averaged relevancy values across all reviewers for the search result you provide.
    /// - Parameter searchResult: The search result.
    /// - Returns: The relevancy values or nil if the evaluation is incomplete.
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

    /// Returns the relevancy values across all reviewers by the reviewer and for the search result you provide.
    /// - Parameters:
    ///   - searchResult: The search result.
    ///   - reviewer: The reviewer id.
    /// - Returns: The relevancy values or nil if the evaluation is incomplete.
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

    /// Returns the search metrics for a search result as reviewed by the reviewer you provide, if complete.
    /// - Parameters:
    ///   - searchResult: The search result.
    ///   - reviewer: The reviewer id
    func metrics(for searchResult: SearchResult, by reviewer: ReviewerID) -> SearchMetrics? {
        if let relevancyValues = relevancyValues(for: searchResult, by: reviewer) {
            return SearchMetrics(searchResult: searchResult, reviews: relevancyValues)
        }
        return nil
    }

    /// Returns the combined search metrics from all reviews, if complete.
    /// - Parameter searchResult: The search result.
    func medianMetrics(for searchResult: SearchResult) -> SearchMetrics? {
        if let relevancyValues = medianRelevancyValues(for: searchResult) {
            return SearchMetrics(searchResult: searchResult, reviews: relevancyValues)
        }
        return nil
    }
}
