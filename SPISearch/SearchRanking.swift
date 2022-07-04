//
//  SearchRanking.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import Foundation

struct PackageSearchResult: Identifiable, Hashable, Codable {
    var id: String
    var name: String = ""
    var summary: String = ""
    var keywords: [String] = []
}

enum Relevance: Int, CaseIterable, Identifiable, Codable {
    case unknown = -1
    case none = 0
    case partial = 1
    case relevant = 2
    var id: Self { self }
}

struct SearchRank: Identifiable, Codable {
    var id = UUID()
    var queryURI: String
    
    init(id: UUID = UUID(), query: String) {
        self.id = id
        self.queryURI = query
    }
}

struct SearchResultSet: Hashable, Codable {
    var results: [PackageSearchResult] = []
    var matched_keywords: [String] = []
    var nextHref: String?
    var prevHref: String?
    var errorMessage: String = ""

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
