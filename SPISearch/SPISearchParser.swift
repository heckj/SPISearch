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

struct SearchResult {
    var results: [PackageSearchResult] = []
    var matched_keywords: [String] = []
    var nextHref: String?
    var prevHref: String?
    var errorMessage: String?
}

enum SPISearchParser {
    static func search(_ url: String) async -> SearchResult {
        var result = SearchResult()
        guard let url = URL(string: url) else {
            // print("Invalid URL")
            result.errorMessage = "Invalid URL"
            return result
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            // more code to come
            if let httpresponse = response as? HTTPURLResponse {
                if httpresponse.statusCode != 200 {
                    result.errorMessage = httpresponse.debugDescription
                    return result
                }
            }
            let HTMLString = String(data: data, encoding: .utf8)!
            let resultSet = try await SPISearchParser.parse(HTMLString)
            return resultSet
        } catch {
            if let urlerr = error as? URLError {
                // print("URLError")
                // print("unavailableReason: \(String(describing: urlerr.networkUnavailableReason))")
                // print("errorCode: \(String(describing: urlerr.errorCode))")
                // print("localizedDescription: \(String(describing: urlerr.localizedDescription))")
                // print("backgroundTaskCancelledReason: \(String(describing: urlerr.backgroundTaskCancelledReason))")
                // print("failureURLString: \(String(describing: urlerr.failureURLString))")
                result.errorMessage = "\(urlerr.localizedDescription)"
            } else {
                // print("Invalid data")
                result.errorMessage = "Invalid data \(error)"
            }
            return result
        }
    }

    static func parse(_ raw_html: String) async throws -> SearchResult {
        let doc: Document = try SwiftSoup.parse(raw_html)
        var results = SearchResult()

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
