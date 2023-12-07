//
//  SearchRankDocumentOverview.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

import os
import SPISearchResult
import SwiftUI

// default logger
let logger = Logger()

enum ImportError: Error {
    case fileAccessError(url: URL)
    case readError(url: URL)
}

struct SearchRankDocumentOverview: View {
    @Binding var document: SearchRankDocument

    @AppStorage(SPISearchApp.reviewerKey) var localReviewer: String = ""
    @State private var reviewerId: String = ""

    @State private var importerEnabled = false

    private func bestEffortImportFromfileURL(fileURL: URL) throws -> [SearchResult] {
        var searchResults: [SearchResult] = []
        // gain access to the file
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
                            let aSearchResult = try decoder.decode(SPISearchResult.SearchResult.self, from: newDataBlob)
                            searchResults.append(aSearchResult)
                        } catch {
                            logger.warning("Skipping embedded JSON-encoded search result: Unable to decode search result from \(line): \(error), ")
                        }
                    } else {
                        logger.warning("skipping embedded JSON-encoded search result: Unable to convert \(line) back into data using .utf8 encoding.")
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

//    private func captureSearch(localhost: Bool = false) {
//        if let terms = document.searchRanking.storedSearches.first?.searchTerms {
//            Task {
//                let searchResults = await SPISearchParser.recordSearch(terms: terms, localhost: localhost)
//                DispatchQueue.main.async {
//                    document.searchRanking.storedSearches.append(searchResults)
//                }
//            }
//        }
//    }

    var body: some View {
        List {
            Section {
                // only display import on an empty document?
                if document.searchRanking.searchResultCollection.isEmpty {
                    HStack {
                        Spacer()
                        Button("Import", systemImage: "square.and.arrow.down.on.square") {
                            importerEnabled = true
                        }
                        .fileImporter(isPresented: $importerEnabled, allowedContentTypes: [.text]) { result in
                            // # result type is -> URL/error
                            switch result {
                            case let .success(fileURL):
                                do {
                                    for aSearchResult in try bestEffortImportFromfileURL(fileURL: fileURL) {
                                        document.searchRanking.searchResultCollection.append(aSearchResult)
                                    }
                                } catch {
                                    logger.warning("Error importing search results: \(error)")
                                }
                            case let .failure(error):
                                logger.warning("Error attempting to import search results: \(error)")
                            }
                        }
                        Spacer()
                    }
                } else {
                    Text("Collection of \(document.searchRanking.searchResultCollection.count) searches")
                        .font(.title)
                }
            }
            Section {
                ForEach(document.searchRanking.reviewedEvaluationCollections) { evalCollection in
                    HStack {
                        Text("\(evalCollection.reviewer.name) (\(evalCollection.reviewer.id)) has \(evalCollection.rankings.count) evaluations stored")
                        // RelevanceSetSummaryView(ranking.wrappedValue)
                        NavigationLink("") {
//                            RankResultsView(
//                                searchRankDoc: $document, relevanceRecordBinding: ranking,
//                                recordedSearch: document.searchRanking.combinedRandomizedSearchResult()
//                            )
                        }
                    }
                }
            }
//                header: {
//                VStack(alignment: .leading) {
//                    Text("Rankings")
//                        .font(.title)
//                    Button {
//                        if !localReviewer.isEmpty {
//                            document.searchRanking.addRelevanceSet(for: localReviewer)
//                        }
//                    } label: {
//                        Image(systemName: "plus.circle")
//                    }
//                    #if os(iOS)
//                    .buttonStyle(.borderless)
//                    #endif
//                }
//            }
            Section {
                ForEach(document.searchRanking.searchResultCollection) { searchResult in
                    NavigationLink("Search on \(searchResult.timestamp.formatted(date: .abbreviated, time: .omitted))") {
                        Text("\(searchResult.query) -> \(searchResult.packages.count) packages")
//                        RecordedSearchResultView(storedSearch,
//                                                 relevanceRecords: document.searchRanking.relevanceSets,
//                                                 relevancyValues: document.searchRanking.medianRelevancyRanking)
                    }
                }
            }
        }
        #if os(macOS)
        .listStyle(.sidebar)
        #endif
    }

    init(_ document: Binding<SearchRankDocument>) {
        _document = document
    }
}

struct SearchRankDocumentOverview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchRankDocumentOverview(.constant(SearchRankDocument()))
        }
    }
}
