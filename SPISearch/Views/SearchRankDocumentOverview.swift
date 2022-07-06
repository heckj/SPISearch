//
//  SearchRankDocumentOverview.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

import SwiftUI

struct SearchRankDocumentOverview: View {
    @Binding var document: SearchRankDocument
    var body: some View {
        VStack(alignment: .leading) {
            Text("Stored Searches")
                .font(.headline)
            HStack {
                ForEach(document.searchranking.storedSearches) { result in
                    SearchResultSetSummaryView(result)
                }
            }
            Text("Relevance Rankings")
                .font(.headline)
            if document.searchranking.relevanceSets.isEmpty {
                Text("No relevance rankings stored.")
            } else {
                HStack {
                    Text("hi")
                }
            }
            Spacer()
        }
    }

    init(_ document: Binding<SearchRankDocument>) {
        _document = document
    }
}

struct SaerchRankDocumentOverview_Previews: PreviewProvider {
    static var previews: some View {
        SearchRankDocumentOverview(.constant(SearchRankDocument(.example)))
    }
}
