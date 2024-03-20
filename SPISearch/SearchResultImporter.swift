import Foundation
import OSLog
import SPISearchResult

enum SearchResultImporter {
    enum ImportError: Error {
        case fileAccessError(url: URL)
        case readError(url: URL)
    }

    static func bestEffort(from fileURL: URL) throws -> [SearchResult] {
        var searchResults: [SearchResult] = []
        // The fileURL provided is a security scoped resource - so we need to request
        // (synchronous) access before we can use it. It's the stuff returned from
        // the .fileImporter() view modifier in SwiftUI
        let gotAccess = fileURL.startAccessingSecurityScopedResource()
        if !gotAccess { throw ImportError.fileAccessError(url: fileURL) }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let wholeDamnThing = try String(contentsOf: fileURL, encoding: .utf8)
            wholeDamnThing.enumerateLines { line, _ in
                if !line.starts(with: "#") {
                    if let newDataBlob = line.data(using: .utf8) {
                        do {
                            let aSearchResult = try decoder.decode(SearchResult.self, from: newDataBlob)
                            searchResults.append(aSearchResult)
                        } catch {
                            Logger.app.warning("Skipping embedded JSON-encoded search result: Unable to decode search result from \(line): \(error), ")
                        }
                    } else {
                        Logger.app.warning("skipping embedded JSON-encoded search result: Unable to convert \(line) back into data using .utf8 encoding.")
                    }
                }
            }
        } catch {
            // from try String(contentsOf:encoding:)
            throw ImportError.readError(url: fileURL)
        }
        // release access to the file
        fileURL.stopAccessingSecurityScopedResource()
        return searchResults
    }
}
