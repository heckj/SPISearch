//
//  SPISearchAPI.swift
//  SPISearch
//
//  Created by Joseph Heck on 11/20/23.
//

import Foundation
import SPISearchResult

enum SPIBaseURLs: String {
    case localhost = "http://localhost"
    case dev = "https://staging.swiftpackageindex.com"
    case prod = "https://swiftpackageindex.com"
}

// API docs rendered from OpenAPI declaration
// DEV: https://redocly.github.io/redoc/?url=https://staging.swiftpackageindex.com/openapi/openapi.json
//
// PROD: https://redocly.github.io/redoc/?url=https://swiftpackageindex.com/openapi/openapi.json

func createPackage(from apiPackage: SwiftPackageIndexAPI.SearchResponse.Result.Package) -> SPISearchResult.SearchResult.Package {
    SearchResult.Package(id: .init(owner: apiPackage.repositoryOwner, repository: apiPackage.repositoryName),
                         matching_keywords: apiPackage.keywords,
                         summary: apiPackage.summary,
                         stars: apiPackage.stars)
}

func makeASearchResult(terms: String, from: SPIBaseURLs = .dev) async throws -> SearchResult {
    let apiEndpoint = SwiftPackageIndexAPI(baseURL: from.rawValue, apiToken: "")
    let api_search_results = try await apiEndpoint.search(query: terms, limit: 50)
    var searchPackages: [SearchResult.Package] = []
    var keywords: [String] = []
    var authors: [String] = []
    _ = api_search_results.results.map { res in
        switch res {
        case let .author(author):
            authors.append(author.name)
        case let .keyword(keyword):
            keywords.append(keyword.keyword)
        case let .package(package):
            searchPackages.append(createPackage(from: package))
        }
    }
    return SearchResult(timestamp: Date.now, query: terms, packages: searchPackages)
}
