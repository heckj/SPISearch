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
    var id: UUID = .init()
    private var ratings: [String: Relevance] = [:]

    /// Provides read-only relevance for a package search result.
    func package_relevance(_ packageIdentifier: String) -> Relevance {
        ratings[packageIdentifier, default: .unknown]
    }

    /// Returns the number of entries in the package search result relevance dictionary.
    var count: Int {
        ratings.count
    }

    /// Provides read-write relevance instance for a package search result
    ///
    /// Used to get `Binding` access to a specific instance within the enclosed dictionary.
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
    var id: UUID = .init()
    private var ratings: [String: Relevance] = [:]
    
    /// Returns the number of entries in the keyword relevance dictionary.
    var count: Int {
        ratings.count
    }

    /// Provides read-only relevance for a package search result.
    func package_relevance(_ packageIdentifier: String) -> Relevance {
        ratings[packageIdentifier, default: .unknown]
    }

    /// Provides read-write relevance instance for a package search result.
    ///
    /// Used to get `Binding` access to a specific instance within the enclosed dictionary.
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
    
    /// The relevance reviews for package search results.
    var packages: PackageIdentifierRelevance
    /// The relevance reviews for keywords.
    var keywords: KeywordRelevance
    
    init(_ reviewer: String) {
        id = UUID()
        self.reviewer = reviewer
        packages = PackageIdentifierRelevance()
        keywords = KeywordRelevance()
    }

    static var example: RelevanceRecord {
        var ex = RelevanceRecord("exampler")
        ex.packages["pocketsvg/PocketSVG"] = .relevant
        ex.packages["maxxfrazer/SceneKit-Bezier-Animations"] = .relevant
        ex.packages["fummicc1/SimpleRoulette"] = .relevant
        ex.packages["antoniocasero/Arrows"] = .relevant
        ex.packages["AndreasVerhoeven/BalloonView"] = .relevant
        ex.packages["bradhowes/ArrowView"] = .relevant

        // keyword relevance examples
        ex.keywords["bezier"] = .relevant
        ex.keywords["bezier-path"] = .relevant
        ex.keywords["bezier-animation"] = .relevant
        ex.keywords["bezier-curve"] = .relevant
        ex.keywords["uibezierpath"] = .relevant

        return ex
    }
}
