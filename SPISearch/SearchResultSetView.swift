//
//  SearchResultsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct SearchResultSetView: View {
    let resultSet: SearchResult
    var body: some View {
        if resultSet.errorMessage != nil {
            // Display any error messages in red
            Text(resultSet.errorMessage ?? "")
                .foregroundColor(.red)
                .textSelection(.enabled)
        } else {
            VStack {
                Text("Matched Keywords").font(.title2)
                HStack {
                    ForEach(resultSet.matched_keywords, id: \.self) { word in
                        CapsuleText(word)
                            .textSelection(.enabled)
                    }
                }
                List(resultSet.results) { result in
                    HStack {
                        PackageSearchResultView(result)
                        Spacer()
                        RelevanceReview()
                            .frame(width: 200)
                    }
                    Divider()
                }
                HStack {
                    Text(resultSet.prevHref ?? "")
                    Spacer()
                    Text(resultSet.nextHref ?? "")
                }
            }
            .padding()
        }
    }

    init(_ resultSet: SearchResult) {
        self.resultSet = resultSet
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultSetView(SearchResult.example)
    }
}
