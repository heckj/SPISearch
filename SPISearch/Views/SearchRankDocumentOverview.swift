//
//  SearchRankDocumentOverview.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

import os
import SPISearchResult
import SwiftUI

struct SearchRankDocumentOverview: View {
    @Binding var document: SearchRankDocument

    @AppStorage(SPISearchApp.reviewerKey) var localReviewer: String = ""
    @State private var reviewerId: String = ""

    @State private var importerEnabled = false

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

                            let logger = Logger()
                            // # result type is -> URL/error
                            switch result {
                            case let .success(fileURL):
                                do {
                                    for aSearchResult in try SearchResultImporter.bestEffort(from: fileURL) {
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
