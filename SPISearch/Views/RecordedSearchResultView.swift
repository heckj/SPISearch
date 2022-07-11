//
//  SearchResultsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct RecordedSearchResultView: View {
    let recordedSearch: RecordedSearchResult
    let relevancyValues: ComputedRelevancyValues?
    var body: some View {
        if !recordedSearch.resultSet.errorMessage.isEmpty {
            // Display any error messages in red
            Text(recordedSearch.resultSet.errorMessage)
                .foregroundColor(.red)
                .textSelection(.enabled)
        } else {
            VStack {
                Text("**\(recordedSearch.resultSet.results.count)** results recorded  \(recordedSearch.recordedDate.formatted()) from `\(recordedSearch.host)`")
                    .textSelection(.enabled)
                    .padding(.bottom)

                if let relevancyValues = relevancyValues, let metrics = SearchMetrics(
                    searchResult: recordedSearch,
                    ranking: relevancyValues
                ) {
                    SearchMetricsView(metrics, sparkline: true)
                } else {
                    Text("_**Metrics Unavailable**_")
                }
                ScrollView(.horizontal, showsIndicators: true) {
                    LazyHGrid(rows: [GridItem(.flexible())]) {
                        ForEach(recordedSearch.resultSet.matched_keywords, id: \.self) { word in
                            CapsuleText(word)
                                .textSelection(.enabled)
                                .fixedSize()
                        }
                    }
                }
                .frame(maxHeight: 50)
                List(recordedSearch.resultSet.results) { result in
                    PackageSearchResultView(result)
                    #if os(macOS)
                        Divider()
                    #endif
                }
            }
            .padding()
        }
    }

    init(_ recordedSearch: RecordedSearchResult, relevancyValues: ComputedRelevancyValues? = nil) {
        self.recordedSearch = recordedSearch
        self.relevancyValues = relevancyValues
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordedSearchResultView(
            RecordedSearchResult(recordedDate: Date.now, url: SPISearchParser.hostedURL!, resultSet: SearchResultSet.example)
        )
    }
}
