//
//  SearchResultSet.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//
import Foundation

/// An individual search result that represents a package found from Swift Package Index.
struct PackageSearchResult: Identifiable, Hashable, Codable, Comparable {
    static func < (lhs: PackageSearchResult, rhs: PackageSearchResult) -> Bool {
        lhs.id < rhs.id
    }

    /// The identifier of the search result.
    var id: String
    /// The package name.
    var name: String = ""
    /// The summary of the package provided from the index.
    var summary: String = ""
    /// The list of keywords that were provided with the search result.
    var keywords: [String] = []
}

/// A collection of search results and the keywords matched for a search.
struct SearchResultSet: Identifiable, Hashable, Codable {
    var id: UUID = .init()
    /// The list of individual search results.
    var results: [PackageSearchResult] = []
    /// The list of keywords that the search matched.
    var matched_keywords: [String] = []

    /// The URI string, if available, for the next set of results
    var nextHref: String?
    /// The URI string, if available, for the previous set of results
    var prevHref: String?
    /// Any error messages from the attempted search.
    var errorMessage: String = ""

    /// A sample search result set for `bezier` to use in designing and building views.
    static var example: SearchResultSet {
        var ex = SearchResultSet()
        ex.matched_keywords = ["bezier", "bezier-path", "uibezierpath", "bezier-animation", "bezier-curve"]
        ex.results = [
            PackageSearchResult(id: "pocketsvg/PocketSVG", name: "PocketSVG", summary: "Easily convert your SVG files into CGPaths, CAShapeLayers, and UIBezierPaths", keywords: []),
            PackageSearchResult(id: "maxxfrazer/SceneKit-Bezier-Animations", name: "SCNBezier", summary: "Create animations over Bezier curves of any number of points", keywords: ["bezier", "bezier-animation", "bezier-curve"]),
            PackageSearchResult(id: "fummicc1/SimpleRoulette", name: "SimpleRoulette", summary: "Create Roulette with ease.", keywords: ["bezier"]),
            PackageSearchResult(id: "antoniocasero/Arrows", name: "Arrows", summary: "Arrows is an animated custom view to give feedback about your UI sliding panels.", keywords: ["bezier-path"]),
            PackageSearchResult(id: "AndreasVerhoeven/BalloonView", name: "BalloonView", summary: "A view in the form of a popup balloon. UIBezierPath initializer included!", keywords: []),
            PackageSearchResult(id: "bradhowes/ArrowView", name: "ArrowView", summary: "Simple iOS view that draws a line with an arrow at the end. Uses UIBezierPath for a nice wavy effect.", keywords: ["bezier-path", "uibezierpath"]),
        ]
        return ex
    }
}

/// A recorded search result
struct RecordedSearchResult: Identifiable, Hashable, Codable {
    var id: UUID = .init()
    /// The date the search was recorded.
    var recordedDate: Date
    /// The URL providing the search results.
    ///
    /// In practice, this should be either the hosted version or `localhost` to compare a development version.
    var url: URL
    /// The set of stored search results.
    var resultSet: SearchResultSet

    /// The hostname from the recorded ``url``.
    var host: String {
        URLComponents(string: url.absoluteString)?.host ?? ""
    }

    /// The search term or terms from the recorded ``url``.
    var searchTerms: String {
        URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "query" })?.value ?? ""
    }

    /// The matched keywords found in the recorded search result
    var keywords: [String] {
        resultSet.matched_keywords
    }

    /// The matched package identifiers found in the recorded search result
    var packageIds: [String] {
        resultSet.results.map(\.id)
    }

    init(recordedDate: Date, url: URL, resultSet: SearchResultSet) {
        self.recordedDate = recordedDate
        self.url = url
        self.resultSet = resultSet
    }

    /// An example recorded search result for designing views.
    static var example: RecordedSearchResult = .init(
        recordedDate: Date.now,
        url: URL(string: SPISearchParser.serverHost)!,
        resultSet: SearchResultSet.example
    )
}
