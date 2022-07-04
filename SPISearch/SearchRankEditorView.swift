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
            Text("this is my search rank view/editor view")
        }
        // Applied to the top level view in a macOS App, this controls both the initial size
        // of the window that appears and the maximum size to which it can be expanded.
        .frame(idealWidth: 500, maxWidth: .infinity, idealHeight: 300, maxHeight: .infinity)

    }
}

struct SearchRankEditorView_Previews: PreviewProvider {
    static var previews: some View {
        SearchRankEditorView(ranking: .constant(SearchRankDocument()))
    }
}
