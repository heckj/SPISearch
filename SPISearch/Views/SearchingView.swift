//
//  SearchingView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct SearchingView: View {
    let searchHostURL: URL?
    @State var searchTerms: String = "bezier"
    @State var recordedSearch: RecordedSearchResult? = nil

    var body: some View {
        VStack {
            TextField("Search", text: $searchTerms)
                .onSubmit {
                    Task {
                        recordedSearch = await SPISearchParser.recordSearch(terms: searchTerms)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .padding()
            if let recordedSearch = recordedSearch {
                RecordedSearchResultView(recordedSearch)
                    .padding()
            }
//            Spacer().layoutPriority(1)
            Button("Save as search ranking") {
                print("saving...")
            }.padding()
        }
    }

    init(searchHostURL: URL?,
         searchTerms: String? = nil)
    {
        self.searchHostURL = searchHostURL
        if let searchTerms = searchTerms {
            self.searchTerms = searchTerms
        }
    }
}

struct SearchingView_Previews: PreviewProvider {
    static var previews: some View {
        SearchingView(searchHostURL: SPISearchParser.hostedURL)
    }
}
