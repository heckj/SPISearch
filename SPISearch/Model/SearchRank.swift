//
//  SearchRanking.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import Foundation

/// A type that indicates the perceived relevance of a search result.
enum Relevance: Int, CaseIterable, Identifiable, Codable {
    case unknown = -1
    case none = 0
    case partial = 1
    case relevant = 2
    var id: Self { self }
}

/// The SPISearch data model that encodes searches and ranked relevance reviews for those searches.
struct SearchRank: Identifiable, Codable {
    var id = UUID()
    var queryURI: String

    init(id: UUID = UUID(), query: String) {
        self.id = id
        queryURI = query
    }
}
