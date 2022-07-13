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
    static var serverHost = "https://swiftpackageindex.com/search?query=bezier"
    static var localHost = "http://127.0.0.1:8080/search?query=bezier"

    static func assembleQueryURI(_ terms: String, from baseURL: String) -> URL? {
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.queryItems = [URLQueryItem(name: "query", value: terms)]
        return urlComponents?.url
    }

    static func recordSearch(terms: String, localhost: Bool = false) async -> RecordedSearchResult {
        let searchURL: URL

        if localhost {
            print("prepping to search \(terms) from \(localHost)")
            searchURL = assembleQueryURI(terms, from: localHost)!
        } else {
            print("prepping to search \(terms) from \(serverHost)")
            searchURL = assembleQueryURI(terms, from: serverHost)!
        }
        print("Making query to: \(searchURL.absoluteString)")
        let resultSet = await search(searchURL)
        return RecordedSearchResult(recordedDate: Date.now, url: searchURL, resultSet: resultSet)
    }

    /// Iteratively searches through Swift Package Index for all results, collecting search results for the query URI you provide.
    /// - Parameters:
    ///   - uri: The query URI to use to invoke the search
    ///   - addingTo: The base set of set of results onto which to append, default is an empty set of results.
    ///   - searchHost: The host against which to use, defaulting to the production host at `swiftpackageindex.com`
    /// - Returns: An instance of ``SPISearch/SearchResultSet`` containing the results.
    static func search(_ url: URL, addingTo: SearchResultSet = SearchResultSet()) async -> SearchResultSet {
        // make a copy of the incoming result set, upon which we'll add...
        var result = addingTo

        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = 30 // seconds - any given request
        sessionConfig.timeoutIntervalForResource = 60 // seconds - the whole kit and kaboodle resource
        let session = URLSession(configuration: sessionConfig)

        do {
            let (data, response) = try await session.data(from: url)
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
            if let nextURI = parseResults.nextHref, !nextURI.isEmpty,
               let nextUrl = URL(string: nextURI, relativeTo: url)
            {
                // print("NextURI isn't null: \(nextURI), continuing to request values")
                return await search(nextUrl, addingTo: result)
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

            if !results.results.contains(where: { $0.id == package_result.id }) {
                results.results.append(package_result)
            }
        }

        // Parsing the found keywords for the search:
        let matching_keywords = try doc.select("section.keyword_results ul.keywords li a")
        // print("Found \(matching_keywords.count) matching keywords")
        for keyword_element in matching_keywords {
            let count = try keyword_element.select(".count_tag")
            // If we want to capture the keyword count presented, we have it here...
            // print("count element -> \(try count.text())")

            // This strips out the span that includes the keyword count value
            // for the matched keywords so that it doesn't 'pollute' the keyword
            // value we pull with .text(), which otherwise includes the text from this
            // span node appended on the end.
            try count.remove()
            // DEBUGGING
            // let children = keyword_element.children()
            // print("\(children.count) children: ")
            // for kid in children {
            //     print("kidnode: \(kid) has \(kid.children().count) grandkids")
            //     for grand in kid.children() {
            //         print("grandkidnode: \(grand) has \(grand.children().count) great-grandkids")
            //     }
            // }
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
