//
//  RelevanceRecord.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

/// A type that indicates the perceived relevance of a search result.
enum Relevance: Int, CaseIterable, Identifiable, Codable {
    case unknown = -1
    case none = 0
    case partial = 1
    case relevant = 2
    var id: Self { self }
}

struct RelevanceRecord: Hashable, Codable {
    var reviewer: String
    var _ratings: [String: Relevance]

    subscript(identifier: String) -> Relevance {
        get {
            if let ranking = _ratings[identifier] {
                return ranking
            } else {
                return .unknown
            }
        }
        set(ranking) {
            _ratings[identifier] = ranking
        }
    }
}
