//
//  RelevanceSetSummaryView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

import SwiftUI

struct RelevanceSetSummaryView: View {
    let record: RelevanceRecord

    #if os(iOS)
        @Environment(\.horizontalSizeClass) var horizontalSizeClass
        var body: some View {
            if horizontalSizeClass == .compact {
                HStack {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.largeTitle)
                    Text("\(record.reviewer)")
                        .font(.callout)
                }
            } else {
                HStack(alignment: .center) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text("reviewer: \(record.reviewer)")
                        Text("\(record.packages.count) package and \(record.keywords.count) keyword entries")
                    }
                }
            }
        }
    #else
        var body: some View {
            HStack(alignment: .center) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text("reviewer: \(record.reviewer)")
                    Text("\(record.packages.count) package and \(record.keywords.count) keyword entries")
                }
            }
        }
    #endif

    init(_ record: RelevanceRecord) {
        self.record = record
    }
}

struct RelevanceSetSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RelevanceSetSummaryView(RelevanceRecord.example)
    }
}
