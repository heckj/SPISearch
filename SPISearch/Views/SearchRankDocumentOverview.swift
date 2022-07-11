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

    private func captureSearch(localhost: Bool = false) {
        if let terms = document.searchRanking.storedSearches.first?.searchTerms {
            Task {
                let searchResults = await SPISearchParser.recordSearch(terms: terms, localhost: localhost)
                DispatchQueue.main.async {
                    document.searchRanking.storedSearches.append(searchResults)
                }
            }
        }
    }

    var body: some View {
        List {
            Section {
                Text("Searches for **\(document.searchRanking.storedSearches.first?.searchTerms ?? "")**")
                    .font(.title)
            }
            Section {
                ForEach($document.searchRanking.relevanceSets) { ranking in
                    HStack {
                        RelevanceSetSummaryView(ranking.wrappedValue)
                        NavigationLink("") {
                            RankResultsView(
                                searchRankDoc: $document, relevanceRecordBinding: ranking,
                                recordedSearch: document.searchRanking.combinedRandomizedSearchResult()
                            )
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Rankings")
                        .font(.title)
                    Spacer()
                    Button {
                        if !localReviewer.isEmpty {
                            document.searchRanking.addRelevanceSet(for: localReviewer)
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title)
                    }
                }
            }
            Section {
                ForEach(document.searchRanking.storedSearches) { storedSearch in
                    NavigationLink("Search on \(storedSearch.recordedDate.formatted(date: .abbreviated, time: .omitted)) (\(storedSearch.host))") {
                        RecordedSearchResultView(storedSearch, relevancyValues: document.searchRanking.medianRelevancyRanking)
                    }
                }
            } header: {
                HStack {
                    Text("Stored Searches")
                        .font(.title)
                    Spacer()
                    Menu {
                        Button("swiftpackageindex.com") {
                            print("server")
                            captureSearch()
                        }
                        #if os(macOS)
                            Button("localhost") {
                                print("server")
                                captureSearch(localhost: true)
                            }
                        #endif
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title)
                    }
                }
            }
        }
        #if os(macOS)
        .listStyle(.sidebar)
        #endif
        .sheet(isPresented: $showingSheet) {
            ConfigureReviewer(.constant(SearchRank.extendedExample))
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
            SearchRankDocumentOverview(.constant(SearchRank.extendedExample))
        }
    }
}
