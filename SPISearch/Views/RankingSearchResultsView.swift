//
//  RankingSearchResultsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import SwiftUI

struct RankingSearchResultsView: View {
    @Binding var rankdoc: SearchRank
    var body: some View {
        HStack {
            RecordedSearchResultView(rankdoc.storedSearches.first!)
        }
    }
}

struct RankingSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        RankingSearchResultsView(rankdoc: .constant(SearchRank.example))
    }
}
