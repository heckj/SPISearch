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
    
    func relevanceValue(binary: Bool = false) -> Double {
        let graduatedValue: Double
        switch self {
        case .relevant:
            graduatedValue = 1
        case .partial:
            graduatedValue = 0.5
        case .no, .unknown:
            graduatedValue = 0
        }
        if binary {
            // if we want a yes/no threshold value, then collapse the 0.5 down to 0.
            return floor(graduatedValue)
        }
        return graduatedValue
    }
}

struct PackageIdentifierRelevance: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var ratings: [String: Relevance] = [:]
    
    /// Provides read-only relevance for a package search result.
    func package_relevance(_ packageIdentifier: String) -> Relevance {
        return ratings[packageIdentifier, default: .unknown]
    }
    
    /// Provides read-write relevance instance for a package search result
    subscript(identifier: String) -> Relevance {
        get {
            if let ranking = ratings[identifier] {
                return ranking
            } else {
                return .unknown
            }
        }
        set(ranking) {
            ratings[identifier] = ranking
        }
    }
}

struct KeywordRelevance: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var ratings: [String: Relevance] = [:]
    
    /// Provides read-only relevance for a package search result.
    func package_relevance(_ packageIdentifier: String) -> Relevance {
        return ratings[packageIdentifier, default: .unknown]
    }
    
    /// Provides read-write relevance instance for a package search result
    subscript(identifier: String) -> Relevance {
        get {
            if let ranking = ratings[identifier] {
                return ranking
            } else {
                return .unknown
            }
        }
        set(ranking) {
            ratings[identifier] = ranking
        }
    }
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
    
//    /// A dictionary of the relevance reviews for keywords.
//    var keyword_ratings: [String: Relevance]
//
//    /// Provides read-only relevance for a keyword.
//    func keyword_relevance(_ key: String) -> Relevance {
//        return keyword_ratings[key, default: .unknown]
//    }
//
//    /// Provides read-only relevance value for a keyword.
//    func keyword_relevance_value(_ key: String) -> Double {
//        return keyword_ratings[key, default: .unknown].relevanceValue()
//    }
    
    /// Provides read-only relevance for a package search result.
    func package_relevance(_ packageIdentifier: String) -> Relevance {
        return _ratings[packageIdentifier, default: .unknown]
    }
    
    /// Provides read-write relevance instance for a package search result
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
//        keyword_ratings = [:]
    }

    static var example: RelevanceRecord {
        var ex = RelevanceRecord("exampler")
        ex._ratings["pocketsvg/PocketSVG"] = .relevant
        ex._ratings["maxxfrazer/SceneKit-Bezier-Animations"] = .relevant
        ex._ratings["fummicc1/SimpleRoulette"] = .relevant
        ex._ratings["antoniocasero/Arrows"] = .relevant
        ex._ratings["AndreasVerhoeven/BalloonView"] = .relevant
        ex._ratings["bradhowes/ArrowView"] = .relevant
        
        // keyword relevance examples
//        ex.keyword_ratings["bezier"] = .relevant
//        ex.keyword_ratings["bezier-path"] = .relevant
//        ex.keyword_ratings["bezier-animation"] = .relevant
//        ex.keyword_ratings["bezier-curve"] = .relevant
//        ex.keyword_ratings["uibezierpath"] = .relevant
        
        return ex
    }
}
