//
//  SearchMetricsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/9/22.
//

import SwiftUI

struct SearchMetricsView: View {
    let metrics: SearchMetrics
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }

    init(_ metrics: SearchMetrics) {
        self.metrics = metrics
    }
}

struct SearchMetricsView_Previews: PreviewProvider {
    static var previews: some View {
        if let metrics = SearchMetrics(
            searchResult: RecordedSearchResult.example,
            ranking: RelevanceRecord.example.computedValues()
        ) {
            SearchMetricsView(metrics)
        } else {
            Text("Invalid search metrics view")
        }
    }
}
