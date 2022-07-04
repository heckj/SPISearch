//
//  SearchResult.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct PackageSearchResultView: View {
    let result: PackageSearchResult
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Text(result.name)
                    .font(.title)
                    .textSelection(.enabled)
                Text("\(result.id)")
                    .font(.callout)
                    .textSelection(.enabled)
            }
            HStack(alignment: .firstTextBaseline) {
                ForEach(result.keywords, id: \.self) { word in
                    CapsuleText(word)
                        .textSelection(.enabled)
                }
            }
            Text(result.summary)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
    }

    init(_ result: PackageSearchResult) {
        self.result = result
    }
}

struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        PackageSearchResultView(SearchResultSet.example.results[1])
    }
}
