//
//  SearchMetricsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/9/22.
//

#if canImport(Charts)
    import Charts
#endif
import SwiftUI

struct SearchMetricsView: View {
    let metrics: SearchMetrics
    let sparkline: Bool
    var body: some View {
        if sparkline {
            HStack {
                Spacer()
                Text("P: \(metrics.precision.formatted(.percent)) R: \(metrics.recall.formatted(.percent)) MRR: \(metrics.meanReciprocalRank.formatted(.percent)) NDCG: \(metrics.ndcg.formatted(.percent))")
                Spacer()
            }.padding(.horizontal)
        } else {
            VStack {
                #if canImport(Charts)
                    if #available(iOS 16.0, macOS 13.0, *) {
                        Chart {
                            BarMark(x: .value("metric", "precision"),
                                    y: .value("precision", metrics.precision))
                            BarMark(x: .value("metric", "recall"),
                                    y: .value("recall", metrics.recall))
                            BarMark(x: .value("metric", "mean rank"),
                                    y: .value("mean rank", metrics.meanReciprocalRank))
                            BarMark(x: .value("metric", "NDCG"),
                                    y: .value("NDCG", metrics.ndcg))
                        }.frame(maxHeight: 50)
                    }
                #else
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
                        Text("NDCG:")
                        Text(metrics.ndcg.formatted(.percent))
                    }
                #endif
            }
        }
    }

    init(_ metrics: SearchMetrics, sparkline: Bool = false) {
        self.metrics = metrics
        self.sparkline = sparkline
    }
}

struct SearchMetricsView_Previews: PreviewProvider {
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
