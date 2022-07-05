//
//  SearchRanking.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import Foundation

/// The SPISearch data model that encodes searches and ranked relevance reviews for those searches.
struct SearchRank: Identifiable, Codable {
    var id = UUID()

    var searchResults: [RecordedSearchResult] = []
    var rankings: [RelevanceRecord] = []

    init(id: UUID = UUID(), _ result: RecordedSearchResult? = nil) {
        self.id = id
        if let result = result {
            searchResults.append(result)
        }
    }

    static var example: SearchRank {
        SearchRank(RecordedSearchResult.example)
    }
}
