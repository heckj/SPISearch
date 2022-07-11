//
//  SearchResultSetSummaryView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

import SwiftUI

struct SearchResultSetSummaryView: View {
    let searchResultSet: RecordedSearchResult
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "doc.text")
                .font(.largeTitle)
            VStack(alignment: .leading) {
                Text("\(searchResultSet.recordedDate.formatted(date: .abbreviated, time: .omitted))")
//                Text("\(searchResultSet.resultSet.results.count) search results")
//                Text("\(searchResultSet.resultSet.matched_keywords.count) keyword results")
            }
        }
    }

    init(_ searchResultSet: RecordedSearchResult) {
        self.searchResultSet = searchResultSet
    }
}

private struct SearchResultSetSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultSetSummaryView(RecordedSearchResult.example)
    }
}
