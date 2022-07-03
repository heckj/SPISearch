//
//  SearchResultsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct SearchResultsView: View {
    let resultSet: SearchResult
    var body: some View {
        VStack {
            Text("Matched Keywords").font(.title2)
            HStack {
                ForEach(resultSet.matched_keywords, id: \.self) { word in
                    CapsuleText(word)
                }
            }
            List(resultSet.results) { result in
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(result.name)
                            .font(.title)
                        ForEach(result.keywords, id: \.self) { word in
                            CapsuleText(word)
                        }
                    }
                    Text(result.summary)
                        .fixedSize(horizontal: false, vertical: true)
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

    init(_ resultSet: SearchResult) {
        self.resultSet = resultSet
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(SearchResult())
    }
}
