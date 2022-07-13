//
//  SearchResultsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct RecordedSearchResultView: View {
    let recordedSearch: RecordedSearchResult
    let relevanceRecords: [RelevanceRecord]
    let averageRelevancyValues: ComputedRelevancyValues?
    @State private var selectedRelevanceRecord: String = ""

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

                HStack {
                    Text("Ranking set")
                    Picker("", selection: $selectedRelevanceRecord) {
                        Text("average (if available)").tag("")
                        ForEach(relevanceRecords) { record in
                            Text(record.reviewer).tag(record.reviewer)
                        }
                    }
                }

                if let relevancyValues = averageRelevancyValues,
                   let metrics = SearchMetrics(
                       searchResult: recordedSearch,
                       ranking: relevancyValues
                   )
                {
                    SearchMetricsView(metrics)
                } else if let record = relevanceRecords.first(
                    where: { $0.reviewer == selectedRelevanceRecord })
                {
                    Text("Selected metrics values: \(String(describing: record))")
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
                if let relevanceRecord = relevanceRecords.first(
                    where: { $0.reviewer == selectedRelevanceRecord })
                {
                    List(recordedSearch.resultSet.results) { result in
                        HStack {
                            PackageSearchResultView(result)
                            Spacer()
                            RelevanceResultView(relevanceRecord.packages[result.id])
                        }
                        #if os(macOS)
                            Divider()
                        #endif
                    }
                } else {
                    List(recordedSearch.resultSet.results) { result in
                        PackageSearchResultView(result)
                        #if os(macOS)
                            Divider()
                        #endif
                    }
                }
            }
            .padding()
        }
    }

    init(_ recordedSearch: RecordedSearchResult,
         relevanceRecords: [RelevanceRecord] = [],
         relevancyValues: ComputedRelevancyValues? = nil)
    {
        self.recordedSearch = recordedSearch
        self.relevanceRecords = relevanceRecords
        averageRelevancyValues = relevancyValues
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordedSearchResultView(
            RecordedSearchResult(
                recordedDate: Date.now,
                url: URL(string: SPISearchParser.serverHost)!,
                resultSet: SearchResultSet.example
            ),
            relevanceRecords: [],
            relevancyValues: nil
        )
        RecordedSearchResultView(
            RecordedSearchResult(
                recordedDate: Date.now,
                url: URL(string: SPISearchParser.serverHost)!,
                resultSet: SearchResultSet.example
            ),
            relevanceRecords: [RelevanceRecord.example],
            relevancyValues: RelevanceRecord.example.computedValues()
        )
    }
}
