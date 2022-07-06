//
//  SearchRankView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import SwiftUI

struct SearchRankEditorView: View {
    @Binding var ranking: SearchRankDocument
    var body: some View {
        VStack {
            if let firstSearchResults = ranking.searchrank.searchResults.first {
                Text("this is my search rank view/editor view")
                RecordedSearchResultView(firstSearchResults)
            } else {
                Text("Using SearchingView to initialize the empty document")
                SearchingView(searchDoc: $ranking, searchHostURL: SPISearchParser.hostedURL)
            }
        }
        // Applied to the top level view in a macOS App, this controls both the initial size
        // of the window that appears and the maximum size to which it can be expanded.
        .frame(idealWidth: 500, maxWidth: .infinity, idealHeight: 300, maxHeight: .infinity)
        // in macOS 13+ this can be replaced with the .defaultSize(width: 1000, height: 650)
        // modifier on the enclosing scene to create a default size experience.
    }
}

struct SearchRankEditorView_Previews: PreviewProvider {
    static var previews: some View {
        SearchRankEditorView(ranking: .constant(SearchRankDocument()))
    }
}
