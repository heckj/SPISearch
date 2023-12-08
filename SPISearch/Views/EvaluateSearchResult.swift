//
//  RankResultsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import SPISearchResult
import SwiftUI

struct EvaluateSearchResult: View {
    @AppStorage(SPISearchApp.reviewerIDKey) var localReviewerId: String = UUID().uuidString
    @AppStorage(SPISearchApp.reviewerNameKey) var localReviewerName: String = ""
    // To allow creating a local reviewer document if the
    // document doesn't already have one.
    @Binding var document: SearchRankDocument

    // The search result to display for the purposes of
    // ranking the matched keywords and search results.
    let searchResult: SearchResult
    let package: SearchResult.Package

    func highlightColor(_ relevance: Relevance) -> Color {
        switch relevance {
        case .unknown:
            return .yellow.opacity(0.5)
        case .not:
            return .gray.opacity(0.1)
        case .partial:
            return .green.opacity(0.2)
        case .relevant:
            return .green.opacity(0.5)
        }
    }

    var body: some View {
        VStack {
            Text("Query Terms: \(searchResult.query)")
            HStack(alignment: .firstTextBaseline) {
                Text("Keywords:")
                ForEach(searchResult.keywords, id: \.self) { word in
                    CapsuleText(word)
                        .textSelection(.enabled)
                        .fixedSize()
                }
            }
            Divider()
            SearchResultPackageView(package, keywords: searchResult.keywords)
                .padding(.horizontal)
            Divider()
            Text("Select Relevance Here")
        }
    }

    init(searchRankDoc: Binding<SearchRankDocument>,
         searchResult: SearchResult,
         package: SearchResult.Package)
    {
        _document = searchRankDoc
        self.searchResult = searchResult
        self.package = package
    }
}

struct RankingSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        EvaluateSearchResult(
            searchRankDoc: .constant(SearchRankDocument(SearchResult.exampleCollection)),
            searchResult: SearchResult.exampleCollection[1], 
            package: SearchResult.exampleCollection[1].packages[1]
        )
    }
}
