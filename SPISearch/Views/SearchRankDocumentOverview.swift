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
                .font(.title)
            HStack(alignment: .top) {
                ForEach(document.searchRanking.storedSearches) { result in
                    SearchResultSetSummaryView(result)
                        .padding().border(.gray)
                }
                Spacer()
            }
            Text("Relevance Rankings")
                .font(.title)
            if document.searchRanking.relevanceSets.isEmpty {
                Text("No relevance rankings stored.")
            } else {
                HStack(alignment: .top) {
                    ForEach(document.searchRanking.relevanceSets) { ranking in
                        VStack {
                            RelevanceSetSummaryView(ranking)
                            Button {
                                print("deleting \(ranking.id)")
                            } label: {
                                Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                    .font(.title)
                            }

                        }.padding().border(.gray)
                    }
                }
            }
            Spacer()
        }.border(.blue)
    }

    init(_ document: Binding<SearchRankDocument>) {
        _document = document
    }
}

struct SaerchRankDocumentOverview_Previews: PreviewProvider {
    static func extendedExample() -> SearchRankDocument {
        var doc = SearchRankDocument(.example)
        doc.searchRanking.relevanceSets.append(RelevanceRecord.example)
        return doc
    }

    static var previews: some View {
        SearchRankDocumentOverview(.constant(extendedExample()))
    }
}
