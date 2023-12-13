import SPISearchResult
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    /// The Universal Type Identifier for a ``SPISearch/SearchRankDocument``
    static var SPISearchRank: UTType {
        UTType(exportedAs: "com.github.heckj.SPISearch.searchrank", conformingTo: .json)
    }
}

/// The document wrapper around the struct-based `Codable` data model for the app: ``SPISearch/SearchRank``.
struct SearchRankDocument: FileDocument {
    var searchRanking: SearchRank

    init(_ searchResultCollection: [SPISearchResult.SearchResult] = []) {
        searchRanking = SearchRank(id: UUID(), searchResultCollection)
    }

    init(_ searchRank: SearchRank) {
        searchRanking = searchRank
    }

    static var readableContentTypes: [UTType] { [.SPISearchRank] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        searchRanking = try JSONDecoder().decode(SearchRank.self, from: data)
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(searchRanking)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.preferredFilename = "RankedSPISearch"
        return fileWrapper
    }
}
