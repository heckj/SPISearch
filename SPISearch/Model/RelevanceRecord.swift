//
//  RelevanceRecord.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//
import Foundation

/// A type that indicates the perceived relevance of a search result.
enum Relevance: Int, CaseIterable, Identifiable, Codable {
    case unknown = -1
    case no = 0
    case partial = 1
    case relevant = 2
    var id: Self { self }
}

/// The recorded relevance ratings for a set of search results.
///
/// Each relevance record should be specific to an individual, hence the ``reviewer`` property on it.
/// A complete set of relevance ratings includes a dictionary entry for every search result identifier in
/// the collection of search results stored in a SearchRank document.
struct RelevanceRecord: Identifiable, Hashable, Codable {
    var id: UUID
    /// The name (or identifier) for the person providing the relevance review.
    var reviewer: String
    /// A dictionary of the relevance reviews, keyed by identifier of individual search results.
    var _ratings: [String: Relevance]

    func relevanceValue(_ id: String, binary: Bool = false) -> Double {
        let graduatedValue: Double
        switch _ratings[id] {
        case .relevant:
            graduatedValue = 1
        case .partial:
            graduatedValue = 0.5
        case nil, .no, .unknown:
            graduatedValue = 0
        }
        if binary {
            // if we want a yes/no threshold value, then collapse the 0.5 down to 0.
            return floor(graduatedValue)
        }
        return graduatedValue
    }

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

    init(_ reviewer: String) {
        id = UUID()
        self.reviewer = reviewer
        _ratings = [:]
    }

    static var example: RelevanceRecord {
        var ex = RelevanceRecord("exampler")
        ex._ratings["pocketsvg/PocketSVG"] = .relevant
        ex._ratings["maxxfrazer/SceneKit-Bezier-Animations"] = .relevant
        ex._ratings["fummicc1/SimpleRoulette"] = .relevant
        ex._ratings["antoniocasero/Arrows"] = .relevant
        ex._ratings["AndreasVerhoeven/BalloonView"] = .relevant
        ex._ratings["bradhowes/ArrowView"] = .relevant
        return ex
    }
}
