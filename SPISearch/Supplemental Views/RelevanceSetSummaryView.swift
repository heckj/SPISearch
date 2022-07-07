//
//  RelevanceSetSummaryView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

import SwiftUI

struct RelevanceSetSummaryView: View {
    let record: RelevanceRecord
    var body: some View {
        VStack {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.largeTitle)
            Text(record.reviewer)
            Text("\(record._ratings.count) entries")
        }
    }

    init(_ record: RelevanceRecord) {
        self.record = record
    }
}

struct RelevanceSetSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RelevanceSetSummaryView(RelevanceRecord.example)
    }
}
