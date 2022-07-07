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
    static func extendedExample() -> SearchRankDocument {
        var doc = SearchRankDocument(.example)
        var secondSearch = RecordedSearchResult.example
        secondSearch.id = UUID()
        doc.searchRanking.storedSearches.append(secondSearch)
        doc.searchRanking.relevanceSets.append(RelevanceRecord.example)
        var secondRanking = RelevanceRecord.example
        secondRanking.id = UUID()
        secondRanking.reviewer = "heckj"
        doc.searchRanking.relevanceSets.append(secondRanking)
        return doc
    }

    static var previews: some View {
        SearchRankTabView(.constant(extendedExample()))
    }
}
