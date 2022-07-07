//
//  RankingSearchResultsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import SwiftUI

struct RankingSearchResultsView: View {
    @Binding var ranking: RelevanceRecord
    let recordedSearch: RecordedSearchResult
    var body: some View {
        VStack {
            List(recordedSearch.resultSet.results) { result in
                HStack {
                    PackageSearchResultView(result)
                    Spacer()
                    RelevanceSelectorView($ranking[result.id])
                }
                #if os(macOS)
                    Divider()
                    // replace with `.listRowSeparator(.visible)` for macOS 13+
                #endif
            }
        }
    }

    init(ranking: Binding<RelevanceRecord>, recordedSearch: RecordedSearchResult) {
        _ranking = ranking
        self.recordedSearch = recordedSearch
    }
}

struct RankingSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        RankingSearchResultsView(ranking: .constant(RelevanceRecord("testing")), recordedSearch: RecordedSearchResult.example)
    }
}
