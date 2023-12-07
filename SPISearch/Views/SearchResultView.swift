//
//  SearchResultView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SPISearchResult
import SwiftUI

struct SearchResultView: View {
    let recordedSearch: SearchResult

    var body: some View {
        VStack {
            Text("**\(recordedSearch.packages.count)** results recorded  \(recordedSearch.timestamp.formatted())")
                .textSelection(.enabled)

            Form {
                Section("Query") {
                    Text(recordedSearch.query)
                }
                Section("Matched Keywords") {
                    ScrollView(.horizontal, showsIndicators: true) {
                        LazyHGrid(rows: [GridItem(.flexible())]) {
                            ForEach(recordedSearch.keywords, id: \.self) { word in
                                CapsuleText(word)
                                    .textSelection(.enabled)
                                    .fixedSize()
                            }
                        }
                    }
                    .frame(maxHeight: 50)
                }
                Section("\(recordedSearch.packages.count) Packages") {
                    List(recordedSearch.packages) { package in
                        Text("\(package.id.description): \(package.summary ?? "")")
                        // PackageSearchResultView(result)
//                        #if os(macOS)
//                            Divider()
//                        #endif
                    }
                }
            }
        }
        .padding()
    }

    init(_ recordedSearch: SearchResult) {
        self.recordedSearch = recordedSearch
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultView(
            SearchResult.exampleCollection[0]
        )
        SearchResultView(
            SearchResult.exampleCollection[1]
        )
    }
}
