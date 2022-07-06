//
//  SearchRanking.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import Foundation

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
}
