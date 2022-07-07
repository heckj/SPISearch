//
//  SearchRankTabView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/7/22.
//

import SwiftUI

struct SearchRankTabView: View {
    @Binding var ranking: SearchRankDocument
    var body: some View {
        TabView {
            SearchRankDocumentOverview($ranking)
                .tabItem {
                    Label("Overview", systemImage: "doc.richtext")
                }
            RankingReviewerView($ranking)
                .tabItem {
                    Label("Ranking", systemImage: "chart.bar.doc.horizontal")
                }
        }
    }

    init(_ ranking: Binding<SearchRankDocument>) {
        _ranking = ranking
    }
}

struct SearchRankTabView_Previews: PreviewProvider {
    static var previews: some View {
        SearchRankTabView(.constant(SearchRank.extendedExample))
    }
}
