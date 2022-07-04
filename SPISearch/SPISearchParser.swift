//
//  SPISearchParser.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import Foundation
import SwiftSoup

/// A type that invokes a search and collects results from Swift Package Index.
///
/// The results are parsed into a ``SPISearch/SearchResultSet``.
enum SPISearchParser {
    static var serverHost = "https://swiftpackageindex.com/"
    static var localHost = "http://localhost:8080/"
    static var hostedURL: URL? {
        URL(string: serverHost)
    }

    static var localURL: URL? {
        URL(string: localHost)
    }

    /// Iteratively searches through Swift Package Index for all results, collecting search results for the query URI you provide.
    /// - Parameters:
    ///   - uri: The query URI to use to invoke the search
    ///   - addingTo: The base set of set of results onto which to append, default is an empty set of results.
    ///   - searchHost: The host against which to use, defaulting to the production host at `swiftpackageindex.com`
    /// - Returns: An instance of ``SPISearch/SearchResultSet`` containing the results.
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

    /// Parses the HTML you provide into search results.
    /// - Parameter raw_html: The html to parse.
    /// - Returns: The search results encapsulated within ``SPISearch/SearchResultSet``.
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
