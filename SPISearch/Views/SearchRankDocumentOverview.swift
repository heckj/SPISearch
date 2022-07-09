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
#if os(macOS)
        NavigationView {
            VStack(alignment: .leading) { // primary nav view
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
                    NavigationLink("Search on \(result.recordedDate.formatted(date: .abbreviated, time: .omitted)) (\(result.host))") {
                        RecordedSearchResultView(result, relevancyValues: document.searchRanking.medianRelevancyRanking)
                    }
                }
                .listStyle(.bordered)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            selectedRanking = document.searchRanking.relevanceSets.first?.id
        }
#else  // ^^ macOS layout, \/\/ iOS layout
        VStack(alignment: .leading) { // primary nav view
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
                NavigationLink("Search on \(result.recordedDate.formatted(date: .abbreviated, time: .omitted)) (\(result.host))") {
                    RecordedSearchResultView(result, relevancyValues: document.searchRanking.medianRelevancyRanking)
                }
            }
            .listStyle(.plain)
            .frame(maxHeight: 150)
            
            Spacer()
        }
        .padding()
        .onAppear {
            selectedRanking = document.searchRanking.relevanceSets.first?.id
        }
#endif // ^^ iOS layout
    }
// In a tab view under iOS, and under the existing DocumentBrowser nav setup, this shows up as an additional tab - not exactly what we're after...
//        if let selectedSearch = document.searchRanking.storedSearches.first(where: { $0.id == selectedSearchId }) {
//            RecordedSearchResultView(selectedSearch)
//        } else {
//            Text("Select a stored search to review")
//        }
    
    init(_ document: Binding<SearchRankDocument>) {
        _document = document
    }
}

struct SearchRankDocumentOverview_Previews: PreviewProvider {
    static var previews: some View {
        SearchRankDocumentOverview(.constant(SearchRank.extendedExample))
    }
}
