//
//  SearchResultSet.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

/// An individual search result that represents a package found from Swift Package Index.
struct PackageSearchResult: Identifiable, Hashable, Codable {
    var id: String
    var name: String = ""
    var summary: String = ""
    var keywords: [String] = []
}

/// A collection of search results and the keywords matched for a search.
struct SearchResultSet: Hashable, Codable {
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

    /// A sample result-set for `bezier` to use in designing and building views.
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