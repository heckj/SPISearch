//
//  SearchRankDocument.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var SPISearchRank: UTType {
        UTType(exportedAs: "com.github.heckj.SPISearch.searchrank", conformingTo: .json)
    }
}

/// The document wrapper around the struct-based `Codable` data model for the app: ``SPISearch/SearchRank``.
struct SearchRankDocument: FileDocument {
    var searchrank: SearchRank

    init(text: [String] = ["bezier"]) {
        let uri = "/search?query=\(text.joined(separator: "%20"))"
        searchrank = SearchRank(query: uri)
    }

    static var readableContentTypes: [UTType] { [.SPISearchRank] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        searchrank = try JSONDecoder().decode(SearchRank.self, from: data)
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(searchrank)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
}
