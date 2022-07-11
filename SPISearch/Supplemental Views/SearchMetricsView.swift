//
//  SearchMetricsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/9/22.
//

import SwiftUI

struct SearchMetricsView: View {
    let metrics: SearchMetrics
    let sparkline: Bool
    var body: some View {
        if sparkline {
            HStack {
                Spacer()
                Text("P: \(metrics.precision.formatted(.percent)) R: \(metrics.recall.formatted(.percent)) MRR: \(metrics.meanReciprocalRank.formatted(.percent))")
                Spacer()
            }.padding(.horizontal)
        } else {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 90)),
                    GridItem(.adaptive(minimum: 90)),
                ],
                alignment: .center
            ) {
                Text("precision:")
                Text(metrics.precision.formatted(.percent))
                Text("recall:")
                Text(metrics.recall.formatted(.percent))
                Text("MRR:")
                Text(metrics.meanReciprocalRank.formatted(.percent))
            }
        }
    }

    init(_ metrics: SearchMetrics, sparkline: Bool = false) {
        self.metrics = metrics
        self.sparkline = sparkline
    }
}

private struct SearchMetricsView_Previews: PreviewProvider {
    static var previews: some View {
        if let metrics = SearchMetrics(
            searchResult: RecordedSearchResult.example,
            ranking: RelevanceRecord.example.computedValues()
        ) {
            SearchMetricsView(metrics)
            SearchMetricsView(metrics, sparkline: true)
        } else {
            Text("Invalid search metrics view")
        }
    }
}
