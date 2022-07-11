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

    func bindingForRelevanceSet(_ rec: RelevanceRecord) -> Binding<RelevanceRecord>? {
        if let index = document.searchRanking.relevanceSets.firstIndex(where: { $0.id == rec.id }) {
            return Binding(projectedValue: $document.searchRanking.relevanceSets[index])
        }
        return nil
    }

    var body: some View {
        List {
            Section {
                Text("Searches for **\(document.searchRanking.storedSearches.first?.searchTerms ?? "")**")
                    .font(.title)
            }
            Section {
                ForEach(document.searchRanking.relevanceSets) { ranking in
                    HStack {
                        RelevanceSetSummaryView(ranking)
                        if let relevanceBinding = bindingForRelevanceSet(ranking) {
                            NavigationLink("") {
                                RankResultsView(
                                    searchRankDoc: $document, relevanceRecordBinding: relevanceBinding,
                                    recordedSearch: document.searchRanking.combinedRandomizedSearchResult()
                                )
                            }
                        }
                    }
                }
            } header: {
                Text("Relevance Rankings")
                    .font(.title)
            }
            Section {
                ForEach(document.searchRanking.storedSearches) { storedSearch in
                    // edits: <#T##SwiftUI.EditOperations<C>#>,
                    NavigationLink("Search on \(storedSearch.recordedDate.formatted(date: .abbreviated, time: .omitted)) (\(storedSearch.host))") {
                        RecordedSearchResultView(storedSearch, relevancyValues: document.searchRanking.medianRelevancyRanking)
                    }
                }
            } header: {
                Text("Stored Searches")
                    .font(.title)
            }
        }
        #if os(macOS)
        .listStyle(.sidebar)
        #endif
        .toolbar {
            Button("add ranking") {
                if !localReviewer.isEmpty {
                    document.searchRanking.addRelevanceSet(for: localReviewer)
                }
            }
        }
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
