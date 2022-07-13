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
                    .contextMenu {
                        Button {
                            document.searchRanking.relevanceSets.removeAll { $0.id == ranking.id
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                    }
                }
            } header: {
                VStack(alignment: .leading) {
                    Text("Rankings")
                        .font(.title)
                    Button {
                        if !localReviewer.isEmpty {
                            document.searchRanking.addRelevanceSet(for: localReviewer)
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    #if os(iOS)
                    .buttonStyle(.borderless)
                    #endif
                }
            }
            Section {
                ForEach(document.searchRanking.storedSearches) { storedSearch in
                    NavigationLink("Search on \(storedSearch.recordedDate.formatted(date: .abbreviated, time: .omitted)) (\(storedSearch.host))") {
                        RecordedSearchResultView(storedSearch, relevancyValues: document.searchRanking.medianRelevancyRanking)
                    }
                    .contextMenu {
                        Button {
                            document.searchRanking.storedSearches.removeAll {
                                $0.id == storedSearch.id
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            } header: {
                VStack(alignment: .leading) {
                    Text("Stored Searches")
                        .font(.title)
                    HStack {
                        Button {
                            captureSearch()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Image(systemName: "cloud")
                            }
                        }
                        #if os(iOS)
                        .buttonStyle(.borderless)
                        #endif
                        #if os(macOS)
                            Button {
                                captureSearch(localhost: true)
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle")
                                    Image(systemName: "laptopcomputer")
                                }
                            }
                        #endif
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
