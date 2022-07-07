//
//  SearchRankDocumentOverview.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

import SwiftUI

struct SearchRankDocumentOverview: View {
    @Binding var document: SearchRankDocument
    @State var selectedSearchResultSet: UUID? = nil
    @State var selectedRanking: UUID? = nil
    var body: some View {
        VStack(alignment: .leading) {
            Text("Stored Searches")
                .font(.title)
            HStack(alignment: .top) {
                ForEach(document.searchRanking.storedSearches) { result in
                    SearchResultSetSummaryView(result)
                        .padding()
                        .background(selectedSearchResultSet == result.id ? .blue : .clear)
                        .onTapGesture {
                            selectedSearchResultSet = result.id
                        }
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
                                .onTapGesture {
                                    selectedRanking = ranking.id
                                }
                            Button {
                                print("deleting \(ranking.id)")
                            } label: {
                                Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                    .font(.title)
                            }
                        }
                        .padding()
                        .background(selectedRanking == ranking.id ? .blue : .clear)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            selectedSearchResultSet = document.searchRanking.storedSearches.first?.id
            selectedRanking = document.searchRanking.relevanceSets.first?.id
        }
    }

    init(_ document: Binding<SearchRankDocument>) {
        _document = document
    }
}

struct SearchRankDocumentOverview_Previews: PreviewProvider {
    static func extendedExample() -> SearchRankDocument {
        var doc = SearchRankDocument(.example)
        var secondSearch = RecordedSearchResult.example
        secondSearch.id = UUID()
        doc.searchRanking.storedSearches.append(secondSearch)
        doc.searchRanking.relevanceSets.append(RelevanceRecord.example)
        var secondRanking = RelevanceRecord.example
        secondRanking.id = UUID()
        secondRanking.reviewer = "heckj"
        doc.searchRanking.relevanceSets.append(secondRanking)
        return doc
    }

    static var previews: some View {
        SearchRankDocumentOverview(.constant(extendedExample()))
    }
}
