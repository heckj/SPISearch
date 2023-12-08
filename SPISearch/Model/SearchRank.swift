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

    var searchResultCollection: [SearchResult] = []
    var reviewedEvaluationCollections: [RelevanceEvaluation] = []
    var reviewerNames: [RelevanceEvaluation.ID: String]

//    init(id: UUID = UUID(), _ result: SPISearchResult.SearchResult? = nil) {
//        self.id = id
//        if let result {
//            searchResultCollection.append(result)
//        }
//    }

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

    func queueOfReviews(reviewerId: String) -> [String: Set<SearchResult.Package.PackageId>] {
        var packagesToReview: [String: Set<SearchResult.Package.PackageId>] = [:]
        guard let properId = UUID(uuidString: reviewerId) else {
            return [:]
        }
        // build a collection of all the possible summary -> packageId combinations to possibly
        // review
        for search in searchResultCollection {
            let packageIds = search.packages.map(\.id)
            if packagesToReview[search.query] != nil {
                for p in packageIds {
                    packagesToReview[search.query]?.insert(p)
                }
            } else {
                packagesToReview[search.query] = Set(packageIds)
            }
        }

        if let existingReviewSetsForThisPerson = reviewedEvaluationCollections.first(where: { relevanceEval in
            relevanceEval.id == properId
        }) {
            // existingReviewSetsForThisPerson: RelevanceEvaluation is the set of rankings for this person
            let filteredPackagesToReview = packagesToReview.filter { queryTerms, packageId in
                for reviewSet in existingReviewSetsForThisPerson.rankings.filter({ $0.query_terms == queryTerms }) {
                    if reviewSet.reviews.keys.contains(packageId) {
                        return false
                    }
                }
                return true
            }
            return filteredPackagesToReview
        } else {
            // no evaluations by this person
            return packagesToReview
        }
    }

//    /// Load all of the keywords and package results from all of the stored searches, combining them into a sorted order for each
//    /// in order to rank them.
//    /// - Returns: A merged and ordered recorded search result with the synthesis of all the saved searches.
//    func combinedRandomizedSearchResult() -> RecordedSearchResult {
//        // pull all of the individual package results for the stores searches into a set - effectively
//        // deduplicating them (and somewhat randomizing them)
//        let setOfPackageResults: Set<SearchResult.Package> = Set(searchResultCollection.flatMap(\.packages))
//        // capture packages by ID because keywords (or other details) may be different between results
//        let setOfPackageResultIDs: Set<String> = Set(setOfPackageResults.map(\.id))
//        // pull all of the matched keywords for the stores searches into a set
//        let setOfMatchedKeywords: Set<String> = Set(searchResultCollection.flatMap(\.resultSet.matched_keywords))
//        // use the first search - which *should* exist in most cases, with fallbacks to an empty default
//        let firstSearch = searchResultCollection.first
//
//        // This craziness is because search results won't be functionally equivalent between searches.
//        // The initial example I spotted was different keywords, but the end result might happen for other
//        // elements of the search in the future. So we want to group and differentiate *in this case* by
//        // the package Identifier. We iterate through the de-duplicated list of package identifiers
//        // and re-assemble a list of Packages to construct our "fake" set for ranking purposes by choosing
//        // the first package that matches the identifier from the set we pulled from all the stored searches.
//        var pickMergePackages: [PackageSearchResult] = []
//        for pkgId in setOfPackageResultIDs {
//            if let firstFoundPkgThatMatches = setOfPackageResults.first(where: { $0.id == pkgId }) {
//                pickMergePackages.append(firstFoundPkgThatMatches)
//            }
//        }
//        // Assemble a synthetic result - keeping the URL from the first search for terms - with a new UUID
//        // and shuffled results for the ordering of matched keywords and package results.
//        if let firstSearch {
//            return RecordedSearchResult(
//                recordedDate: firstSearch.recordedDate,
//                url: URL(string: firstSearch.url)!,
//                resultSet: SearchResultSet(id: UUID(),
//                                           results: pickMergePackages.sorted(),
//                                           matched_keywords: setOfMatchedKeywords.sorted())
//            )
//        } else {
//            return RecordedSearchResult(
//                recordedDate: Date.now,
//                url: URL(string: SPISearchParser.serverHost)!,
//                resultSet: SearchResultSet(id: UUID(),
//                                           results: pickMergePackages.sorted(),
//                                           matched_keywords: setOfMatchedKeywords.sorted())
//            )
//        }
//    }
//
//    mutating func addRelevanceSet(for reviewer: String) {
//        if !relevanceSets.contains(where: { $0.reviewer == reviewer }) {
//            relevanceSets.append(RelevanceRecord(reviewer))
//        }
//    }
//
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
//
//    /// Returns a list of all the package identifiers from all stored searches.
//    var identifiers: [String] {
//        Set<String>(storedSearches.flatMap { storedSearch in
//            storedSearch.resultSet.results.map(\.id)
//        }).sorted()
//    }
//
//    /// Returns a list of all the keywords from all stored searches.
//    var keywords: [String] {
//        Set<String>(storedSearches.flatMap { storedSearch in
//            storedSearch.resultSet.matched_keywords
//        }).sorted()
//    }
}
