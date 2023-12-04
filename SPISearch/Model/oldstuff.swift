import Foundation

/// A type that encapsulates the relevancy rankings for package search results.
struct PackageIdentifierRelevance: Identifiable, Hashable, Codable {
    var id: UUID = .init()
    var ratings: [String: Relevance] = [:]

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

/// A type that encapsulates the relevancy rankings for matched keywords.
struct KeywordRelevance: Identifiable, Hashable, Codable {
    var id: UUID = .init()
    var ratings: [String: Relevance] = [:]

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

    func isComplete(keywords: [String], packageIDs: [String]) -> Bool {
        // we don't care if they're equal, only that the keywords and packages
        // are contained within the set that we have recorded.
        let allKeywordsAccounted = keywords.allSatisfy { keyword_to_check in
            self.keywords.ratings.keys.contains(keyword_to_check)
        }
        let allPackagesAccounted = packageIDs.allSatisfy { pkgID_to_check in
            packages.ratings.keys.contains(pkgID_to_check)
        }
        return allKeywordsAccounted && allPackagesAccounted
    }

    func computedValues(threshold: Bool = false) -> ComputedRelevancyValues {
        var valueSet = ComputedRelevancyValues()
        for (pkgId, relevancy) in packages.ratings.filter({ $1 != .unknown }) {
            valueSet.packages[pkgId] = relevancy.relevanceValue(binary: threshold)
        }
        for (keyword, relevancy) in keywords.ratings.filter({ $1 != .unknown }) {
            valueSet.keywords[keyword] = relevancy.relevanceValue(binary: threshold)
        }
        return valueSet
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
