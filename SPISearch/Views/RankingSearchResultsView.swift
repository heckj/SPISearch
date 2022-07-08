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

    func highlightColor(_ relevance: Relevance) -> Color {
        switch relevance {
        case .unknown:
            return .yellow.opacity(0.5)
        case .no:
            return .gray.opacity(0.1)
        case .partial:
            return .green.opacity(0.2)
        case .relevant:
            return .green.opacity(0.5)
        }
    }

    var body: some View {
        VStack {
            Text("Relevancy for search terms: **\(recordedSearch.searchTerms)**")
            Text("Ranking has \(ranking.packages.count) of \(recordedSearch.resultSet.results.count) search entries.")
            List(recordedSearch.resultSet.results) { result in
                HStack {
                    PackageSearchResultView(result)
                    Spacer()
                    RelevanceSelectorView($ranking.packages[result.id])
                        .background(highlightColor(ranking.packages[result.id]))
                }
                #if os(macOS)
                    Divider()
                    // replace with `.listRowSeparator(.visible)` for macOS 13+
                #endif
            }
            Text("Ranking has \(ranking.keywords.count) of \(recordedSearch.resultSet.matched_keywords.count) keyword entries.")
            List(recordedSearch.resultSet.matched_keywords, id: \.self) { keyword in
                HStack {
                    CapsuleText(keyword)
                    Spacer()
                    RelevanceSelectorView($ranking.keywords[keyword])
                        .background(highlightColor(ranking.keywords[keyword]))
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
    struct TempView: View {
        @State var rankingRecord: RelevanceRecord = .init("testing")
        var body: some View {
            RankingSearchResultsView(ranking: $rankingRecord, recordedSearch: RecordedSearchResult.example)
        }
    }

    static var previews: some View {
        TempView()
    }
}
