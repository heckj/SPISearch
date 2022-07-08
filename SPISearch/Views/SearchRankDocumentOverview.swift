//
//  SearchRankDocumentOverview.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

import SwiftUI

struct SearchRankDocumentOverview: View {
    @Binding var document: SearchRankDocument
    @State var selectedRanking: UUID? = nil
    @State var selectedSearchId: UUID? = nil
    var body: some View {
        VStack(alignment: .leading) {
            Text("Relevance Rankings")
                .font(.title)
            if document.searchRanking.relevanceSets.isEmpty {
                Text("No relevance rankings stored.")
            } else {
                HStack(alignment: .top) {
                    ForEach(document.searchRanking.relevanceSets) { ranking in
                        VStack {
                            RelevanceSetSummaryView(ranking)
                                .onTapGesture {
                                    selectedRanking = ranking.id
                                }
//                            Button {
//                                print("deleting \(ranking.id)")
//                            } label: {
//                                Image(systemName: "minus.circle.fill").foregroundColor(.red)
//                                    .font(.title)
//                            }
                        }
                        .padding()
                        .background(selectedRanking == ranking.id ? .blue : .clear)
                    }
                }
            }
            Text("Stored Searches for \(document.searchRanking.storedSearches.first?.searchTerms ?? "")")
                .font(.title)
            List(document.searchRanking.storedSearches, selection: $selectedSearchId) {
                result in
                SearchResultSetSummaryView(result)
            }
            #if os(macOS)
            .listStyle(.bordered)
            #else
            .listStyle(.plain)
            .frame(maxHeight: 150)
            #endif

            Spacer()
            if let selectedSearch = document.searchRanking.storedSearches.first(where: { $0.id == selectedSearchId }) {
                RecordedSearchResultView(selectedSearch)
            }
        }
        .padding()
        .onAppear {
            selectedRanking = document.searchRanking.relevanceSets.first?.id
        }
    }

    init(_ document: Binding<SearchRankDocument>) {
        _document = document
    }
}

struct SearchRankDocumentOverview_Previews: PreviewProvider {
    static var previews: some View {
        SearchRankDocumentOverview(.constant(SearchRank.extendedExample))
    }
}
