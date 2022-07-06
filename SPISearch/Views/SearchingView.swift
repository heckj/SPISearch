//
//  SearchingView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct SearchingView: View {
    @Binding var searchDoc: SearchRankDocument
    let searchHostURL: URL?
    @State var searchTerms: String = "bezier"
    @State var searchResults: RecordedSearchResult? = nil

    var body: some View {
        VStack {
            TextField("Search", text: $searchTerms)
                .onSubmit {
                    Task {
                        let searchResults = await SPISearchParser.recordSearch(terms: searchTerms)
                        searchDoc = SearchRankDocument(searchResults)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .padding()
            if let searchResults = searchResults {
                Button(action: { print("doing something about saving this...") }, label: {
                    Text("Export")
                })
                RecordedSearchResultView(searchResults)
                    .padding()
            } else {
                Spacer()
            }
        }
    }

    init(searchDoc: Binding<SearchRankDocument>, searchHostURL: URL?, searchResults _: RecordedSearchResult? = nil) {
        _searchDoc = searchDoc
        self.searchHostURL = searchHostURL
        searchTerms = self.searchDoc.searchrank.searchResults.first?.searchTerms ?? "bezier"
        searchResults = nil
    }
}

struct SearchingView_Previews: PreviewProvider {
    static var previews: some View {
        SearchingView(searchDoc: .constant(SearchRankDocument()), searchHostURL: SPISearchParser.hostedURL)
    }
}
