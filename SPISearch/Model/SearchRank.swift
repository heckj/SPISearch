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

    var searchResults: [SearchResultSet] = []
    var rankings: [RelevanceRecord] = []

    init(id: UUID = UUID()) {
        self.id = id
    }
}
