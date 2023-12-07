//
//  SearchRankDocumentOverview.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

import SwiftUI

struct SearchRankDocumentOverview: View {
    @AppStorage(SPISearchApp.reviewerKey) var localReviewer: String = ""
    @State private var reviewerId: String = ""
    @Binding var document: SearchRankDocument
    @State private var showingSheet = false

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
                Text("Collection of \(document.searchRanking.searchResultCollection.count) searches")
                    .font(.title)
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
        .sheet(isPresented: $showingSheet) {
            Text("CONFIGURE REVIEWER ID")
//            ConfigureReviewer(.constant(SearchRank.extendedExample))
        }
        .onAppear {
            if localReviewer.isEmpty {
                showingSheet = true
            }
        }
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
