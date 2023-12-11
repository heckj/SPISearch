//
//  SearchRankDocumentOverview.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

import SPISearchResult
import SwiftUI

struct SearchRankDocumentOverview: View {
    @Binding var document: SearchRankDocument

    @State private var importerEnabled = false
    @State private var configureReviewerSheetShown = false

    var body: some View {
        List {
            Section("Summary") {
                // only display import on an empty document?
                if document.searchRanking.searchResultCollection.isEmpty {
                    HStack {
                        Spacer()
                        Button {
                            importerEnabled = true
                        } label: {
                            Label("Import", image: "square.and.arrow.down.on.square")
                        }
                        .fileImporter(isPresented: $importerEnabled, allowedContentTypes: [.text]) { result in
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
                    Text("\(document.searchRanking.searchResultCollection.count) search collections")
                    Text("\(document.searchRanking.reviewedEvaluationCollections.count) evaluations")
                }
            }

            Section("Searches") {
                ForEach(document.searchRanking.searchResultCollection) { searchResult in
                    NavigationLink("Search on \(searchResult.timestamp.formatted(date: .abbreviated, time: .omitted))") {
                        SearchResultView(searchResult)
                    }
                }
            }

            Section("Evaluations") {
                // Well - this doesn't work at all on macOS
                NavigationLink("Evaluate") {
                    EvaluateAvailableSearchResults(searchRankDoc: $document)
                }
                ForEach(document.searchRanking.sortedEvaluations, id: \.0) { reviewerId, reviewsets in
                    HStack {
                        Text("\(reviewerId) has \(reviewsets.count) evaluations stored")
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
        }
        #if os(macOS)
        .listStyle(.sidebar)
        #endif
        .sheet(isPresented: $configureReviewerSheetShown) {
            ConfigureReviewer(document: $document)
        }
        .onAppear(perform: {
            // On document open, if there's a set reviewer name, update the document (if needed)
            // to make sure its current.
            let reviewerID = SPISearchApp.reviewerID()
            if document.searchRanking.reviewerNames[reviewerID] == nil {
                // If the reviewer name _isn't_ yet set, then get in their face and get a name
                configureReviewerSheetShown = true
            }
        })
    }

    init(_ document: Binding<SearchRankDocument>) {
        _document = document
    }
}

struct SearchRankDocumentOverview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchRankDocumentOverview(
                .constant(SearchRankDocument(SearchResult.exampleCollection))
            )
        }
    }
}
