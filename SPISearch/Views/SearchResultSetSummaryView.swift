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
        VStack {
            Image(systemName: "doc.text")
                .font(.largeTitle)
            Text("\(searchResultSet.resultSet.results.count) search results")
            Text("\(searchResultSet.resultSet.matched_keywords.count) keyword results")
        }
    }

    init(_ searchResultSet: RecordedSearchResult) {
        self.searchResultSet = searchResultSet
    }
}

struct SearchResultSetSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultSetSummaryView(RecordedSearchResult.example)
    }
}
