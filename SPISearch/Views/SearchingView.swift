//
//  SearchingView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

/// The initial document view that is presented to request and capture search results into the searchrank document.
struct SearchingView: View {
    @Binding var searchDoc: SearchRankDocument
    let searchHostURL: URL?
    @State var searchTerms: String = "bezier"
    @State var searchResults: RecordedSearchResult? = nil

    func commenceSearch(_ terms: String) {
        Task {
            let searchResults = await SPISearchParser.recordSearch(terms: terms)
            DispatchQueue.main.async {
                searchDoc = SearchRankDocument(searchResults)
            }
        }
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: $searchTerms)
                    .onSubmit {
                        commenceSearch(searchTerms)
                    }
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                Button {
                    commenceSearch(searchTerms)
                } label: {
                    Image(systemName: "magnifyingglass.circle.fill")
                }
            }
            .padding()

            if let searchResults = searchResults {
                Button(action: { print("doing something about saving this...") }, label: {
                    Text("Export")
                })
                RecordedSearchResultView(searchResults)
                    .padding()
            } else {
                Form {
                    Text("Enter or update search terms in the text field to retrieve and initial set of search results.")
                }
                Spacer()
            }
        }
    }

    init(searchDoc: Binding<SearchRankDocument>, searchHostURL: URL?, searchResults _: RecordedSearchResult? = nil) {
        _searchDoc = searchDoc
        self.searchHostURL = searchHostURL
        searchTerms = self.searchDoc.searchRanking.storedSearches.first?.searchTerms ?? "bezier"
        searchResults = nil
    }
}

struct SearchingView_Previews: PreviewProvider {
    static var previews: some View {
        SearchingView(searchDoc: .constant(SearchRankDocument()), searchHostURL: SPISearchParser.hostedURL)
    }
}
