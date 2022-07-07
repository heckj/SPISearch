//
//  SearchRanking.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import Foundation
import SwiftUI

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

    var storedSearches: [RecordedSearchResult] = []
    var relevanceSets: [RelevanceRecord] = []

    func combinedRandomizedSearchResult() -> RecordedSearchResult {
        // pull all of the individual package results for the stores searches into a set - effectively
        // deduplicating them (and somewhat randomizing them)
        let setOfPackageResults: Set<PackageSearchResult> = Set(storedSearches.flatMap(\.resultSet.results))
        // pull all of the matched keywords for the stores searches into a set
        let setOfMatchedKeywords: Set<String> = Set(storedSearches.flatMap(\.resultSet.matched_keywords))
        // use the first search - which *should* exist in most cases, with fallbacks to an empty default
        let firstSearch = storedSearches.first
        // Assemble a synthetic result - keeping the URL from the first search for terms - with a new UUID
        // and shuffled results for the ordering of matched keywords and package results.
        return RecordedSearchResult(
            recordedDate: firstSearch?.recordedDate ?? Date.now,
            url: firstSearch?.url ?? SPISearchParser.hostedURL!,
            resultSet: SearchResultSet(id: UUID(),
                                       results: Array(setOfPackageResults).sorted(),
                                       matched_keywords: Array(setOfMatchedKeywords).sorted())
        )
    }

    mutating func addRelevanceSet(for reviewer: String) {
        if !relevanceSets.contains(where: { $0.reviewer == reviewer }) {
            relevanceSets.append(RelevanceRecord(reviewer))
        }
    }

    /// Returns a list of all the search result identifiers from all stored searches.
    var identifiers: [String] {
        storedSearches.flatMap { storedSearch in
            storedSearch.resultSet.results.map(\.id)
        }
    }

    func searchMetrics(searchResult _: RecordedSearchResult, ranking _: RelevanceRecord) {}

    init(id: UUID = UUID(), _ result: RecordedSearchResult? = nil) {
        self.id = id
        if let result = result {
            storedSearches.append(result)
        }
    }

    static var example: SearchRank {
        SearchRank(RecordedSearchResult.example)
    }

    static var extendedExample: SearchRankDocument {
        var doc = SearchRankDocument(.example)
        var secondSearch = RecordedSearchResult.example
        secondSearch.id = UUID()
        doc.searchRanking.storedSearches.append(secondSearch)
        doc.searchRanking.relevanceSets.append(RelevanceRecord.example)
        var secondRanking = RelevanceRecord.example
        secondRanking.id = UUID()
        secondRanking.reviewer = "heckj"
        doc.searchRanking.relevanceSets.append(secondRanking)
        return doc
    }
}
