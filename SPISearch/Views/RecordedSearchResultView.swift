//
//  SearchResultsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct RecordedSearchResultView: View {
    let recordedSearch: RecordedSearchResult
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
                Text("Matched Keywords").font(.title2)
                HStack {
                    ForEach(recordedSearch.resultSet.matched_keywords, id: \.self) { word in
                        CapsuleText(word)
                            .textSelection(.enabled)
                    }
                }
                List(recordedSearch.resultSet.results) { result in
//                    HStack {
                        PackageSearchResultView(result)
//                        Spacer()
//                        RelevanceReview()
//                            .frame(width: 200)
//                    }
//                    Divider()
                }
            }
            .padding()
        }
    }

    init(_ recordedSearch: RecordedSearchResult) {
        self.recordedSearch = recordedSearch
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordedSearchResultView(
            RecordedSearchResult(recordedDate: Date.now, url: SPISearchParser.hostedURL!, resultSet: SearchResultSet.example)
        )
    }
}
