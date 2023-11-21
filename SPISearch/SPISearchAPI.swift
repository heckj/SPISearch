//
//  SPISearchAPI.swift
//  SPISearch
//
//  Created by Joseph Heck on 11/20/23.
//

import Foundation
import PackageListTool // for SwiftPackageIndexAPI

enum SPIBaseURLs: String {
    case localhost = "http://localhost"
    case dev = "https://staging.swiftpackageindex.com"
    case prod = "https://swiftpackageindex.com"
}

// API docs rendered from OpenAPI declaration
// DEV: https://redocly.github.io/redoc/?url=https://staging.swiftpackageindex.com/openapi/openapi.json
//
// PROD: https://redocly.github.io/redoc/?url=https://swiftpackageindex.com/openapi/openapi.json

enum APISearchParser {
    static func recordSearch(terms: String, from: SPIBaseURLs = .dev) async -> RecordedSearchResult {
        let apiEndpoint = SwiftPackageIndexAPI(baseURL: from.rawValue, apiToken: "")
        do {
            let packagesIds = try await apiEndpoint.search(query: terms, limit: 50)
            // x is a list of PackageId - a struct that combines owner and repo to identify the package within the index.
            var resultSet: [PackageSearchResult] = []

            // TODO: convert to a map to transform the results
            for packageId in packagesIds {
                let package = try await apiEndpoint.fetchPackage(packageId: packageId)
                resultSet.append(PackageSearchResult(id: package.url, name: package.title, summary: package.summary ?? "", keywords: []))
            }
            return RecordedSearchResult(recordedDate: Date.now, 
                                        searchterms: terms,
                                        host: from.rawValue,
                                        url: from.rawValue,
                                        resultSet: SearchResultSet(
                                            id: UUID(), results: resultSet,
                                            matched_keywords: [],
                                            errorMessage: ""))
                                            
        } catch {
            return RecordedSearchResult(recordedDate: Date.now, searchterms: terms, host: from.rawValue, url: from.rawValue, resultSet:
                SearchResultSet(
                    id: UUID(), results: [],
                    matched_keywords: [],
                    errorMessage: "\(error)")
            )
        }
    }
}
