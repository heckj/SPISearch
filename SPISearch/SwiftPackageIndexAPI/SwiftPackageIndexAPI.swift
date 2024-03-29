// Copyright Dave Verwer, Sven A. Schmidt, and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

public struct SwiftPackageIndexAPI {
    var baseURL: String
    var apiToken: String

    public init(baseURL: String, apiToken: String) {
        self.baseURL = baseURL
        self.apiToken = apiToken
    }

    struct Error: Swift.Error {
        var message: String
    }

    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    public func fetchPackage(owner: String, repository: String) async throws -> Package {
        let url = URL(string: "\(baseURL)/api/packages/\(owner)/\(repository)")!
        var req = URLRequest(url: url)
        req.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: req)
        assert((response as? HTTPURLResponse)?.statusCode == 200,
               "expected 200, received \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
        return try Self.decoder.decode(Package.self, from: data)
    }

    public func fetchPackage(packageId: PackageId) async throws -> Package {
        try await fetchPackage(owner: packageId.owner, repository: packageId.repository)
    }

    public func search(query: String, limit: Int) async throws -> SearchResponse {
        var urlComponents = URLComponents(string: "\(baseURL)/api/search")
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "pageSize", value: "\(limit)"),
        ]
        guard let url = urlComponents?.url else {
            throw Error(message: "Failed to construct search query URL")
        }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: req)
        if let rawdata = String(bytes: data, encoding: .utf8) {
            print("\(rawdata)")
        }
        let results = try Self.decoder.decode(SearchResponse.self, from: data)
        return results
    }

    public struct SearchResponse: Decodable {
        var hasMoreResults: Bool
        var results: [Result]

        enum Result: Decodable {
            case author(Author)
            case keyword(Keyword)
            case package(Package)

            struct Author: Decodable {
                var name: String
            }

            struct Keyword: Decodable {
                var keyword: String
            }

            struct Package: Decodable {
                var packageURL: String // a partial URL, such as "/heckj/CRDT"
                // var packageId: UUID
                var repositoryOwner: String
                var repositoryName: String
                var packageName: String
                var hasDocs: Bool
                var summary: String?
                var keywords: [String]
                var stars: Int
                var lastActivityAt: Date
            }
            // Package Example
//    {
//      "repositoryName": "CRDT",
//      "packageName": "CRDT",
//      "hasDocs": false,
//      "repositoryOwner": "heckj",
//      "summary": "Conflict-free Replicated Data Types in Swift",
//      "packageId": "BDC2D86B-BDC4-4147-8D58-0FF296E88421",
//      "keywords": [
//        "crdt",
//        "crdt-implementations",
//        "crdts",
//        "swift"
//      ],
//      "stars": 121,
//      "lastActivityAt": "2023-06-20T21:23:04Z",
//      "packageURL": "/heckj/CRDT"
//    }
        }
    }
}
