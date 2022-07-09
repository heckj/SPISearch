//
//  SearchRankDocumentOverview.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

import SwiftUI

struct SearchRankDocumentOverview: View {
    @Binding var document: SearchRankDocument
    var body: some View {
        List {
            Section {
                Text("Searches for  \(document.searchRanking.storedSearches.first?.searchTerms ?? "")")
                    .font(.title)
            }
            Section {
                ForEach(document.searchRanking.relevanceSets) { ranking in
                    HStack {
                        RelevanceSetSummaryView(ranking)
                        NavigationLink("") {
                            Text("editing ranking view")
                        }
                    }
                }
                // TODO: remove this and replace the
                // ranking editor view with nav links above...
                NavigationLink("Rank Stuff", destination: RankingReviewerView($document))
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
