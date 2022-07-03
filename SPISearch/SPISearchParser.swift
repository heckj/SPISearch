//
//  SPISearchParser.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import Foundation
import SwiftSoup

struct PackageSearchResult: Identifiable, Hashable {
    var id: String
    var name: String = ""
    var summary: String = ""
    var keywords: [String] = []
}

struct SearchResultSet {
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

enum SPISearchParser {
    static var serverHost = "https://swiftpackageindex.com/"
    static var localHost = "http://localhost:8080/"
    static var hostedURL: URL? {
        URL(string: serverHost)
    }

    static var localURL: URL? {
        URL(string: localHost)
    }

    static func search(_ uri: String = "/search?query=ping", addingTo: SearchResultSet = SearchResultSet(), at searchHost: URL? = hostedURL) async -> SearchResultSet {
        // make a copy of the incoming result set, upon which we'll add...
        var result = addingTo

        // print("URI incoming is \(uri) with a result set of \(result.results.count) results.")

        guard let url = URL(string: uri, relativeTo: searchHost) else {
            // print("ERROR ASSEMBLING URL: uri: \(uri) base: \(searchHost)")
            result.errorMessage.append("Invalid URL: base: \(String(describing: searchHost)) + uri: \(uri)")
            return result
        }
        // print("URL after composition is \(url)")
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            // more code to come
            if let httpresponse = response as? HTTPURLResponse {
                if httpresponse.statusCode != 200 {
                    result.errorMessage = httpresponse.debugDescription
                }
            }
            let HTMLString = String(data: data, encoding: .utf8)!
            let parseResults = try await SPISearchParser.parse(HTMLString)
            result.matched_keywords.append(contentsOf: parseResults.matched_keywords)
            result.errorMessage.append(parseResults.errorMessage)
            result.results.append(contentsOf: parseResults.results)
            // Check to see if there's more to get (if there's a nextHref defined from the page)
            // and if so, recursively follow those "next page" URLs
            if let nextURI = parseResults.nextHref, !nextURI.isEmpty {
                // print("NextURI isn't null: \(nextURI), continuing to request values")
                return await search(nextURI, addingTo: result)
            }
        } catch {
            if let urlerr = error as? URLError {
                // print("URLError")
                // print("unavailableReason: \(String(describing: urlerr.networkUnavailableReason))")
                // print("errorCode: \(String(describing: urlerr.errorCode))")
                // print("localizedDescription: \(String(describing: urlerr.localizedDescription))")
                // print("backgroundTaskCancelledReason: \(String(describing: urlerr.backgroundTaskCancelledReason))")
                // print("failureURLString: \(String(describing: urlerr.failureURLString))")
                result.errorMessage.append("\(urlerr.localizedDescription)")
            } else {
                // print("Invalid data")
                result.errorMessage.append("Invalid data \(error)")
            }
        }
        return result
    }

    static func parse(_ raw_html: String) async throws -> SearchResultSet {
        let doc: Document = try SwiftSoup.parse(raw_html)
        var results = SearchResultSet()

        let elements = try doc.select("#package_list>li")
        // print("Found \(elements.count) #package_list elements")
        for element in elements {
            /*
             element example:
             <li><a href="/fummicc1/SimpleRoulette"><h4>SimpleRoulette</h4><p>Create Roulette with ease.</p>
             <ul class="keywords matching">
             <li><span>Matching keywords: </span></li>
             <li><span>bezier</span></li>
             </ul>
             <ul class="metadata">
             <li class="identifier"><small>fummicc1/SimpleRoulette</small></li>
             <li class="activity"><small>Active 17 days ago</small></li>
             <li class="stars"><small>13 stars</small></li>
             </ul></a></li>
             */
            let identifier = try element.select("li.identifier").text()
            // print("Identifier: \(identifier)")
            var package_result = PackageSearchResult(id: identifier)

            let keyword_set = try element.select("ul.keywords.matching li")
            if keyword_set.count > 1 {
                for keyword_element in keyword_set.dropFirst() {
                    let keyword = try keyword_element.text()
                    // print("Keyword found: \(keyword)")
                    package_result.keywords.append(keyword)
                }
            }

            // Not sure the href link is all that valuable for this, so skipping capture.
            // let link = try element.select("a").first()!
            // let href = try link.attr("href")
            // print("HREF for link: \(href)")

            package_result.name = try element.select("a h4").text()
            // print("Package name: \(package_result.name)")
            package_result.summary = try element.select("a p").text()

            results.results.append(package_result)
        }

        // Parsing the found keywords for the search:
        let matching_keywords = try doc.select("section.keyword_results ul.keywords li")
        // print("Found \(matching_keywords.count) matching keywords")
        for keyword_element in matching_keywords {
            let keyword = try keyword_element.text()
            // print("found: \(keyword)")
            results.matched_keywords.append(keyword)
        }

        // Parsing pagination if available
        let next_pagination = try doc.select("ul.pagination li.next a")
        let previous_pagination = try doc.select("ul.pagination li.previous a")
        // print("Found \(next_pagination.count) next pagination links")
        results.nextHref = try next_pagination.attr("href")
        // print("Found \(previous_pagination.count) previous pagination links")
        results.prevHref = try previous_pagination.attr("href")

        // let titleString = try doc.title()
        // print("Title: \(titleString)")
        return results
    }
}
