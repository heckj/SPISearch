////
////  SearchRankEditorView.swift
////  SPISearch
////
////  Created by Joseph Heck on 7/4/22.
////
//
// import SwiftUI
//
///// The primary document editor view.
/////
///// If the associated document is "empty" (no searches), this view
///// is responsible for displaying the view to populate and initially create
///// a searchrank document.
// struct SearchRankEditorView: View {
//    @Binding var document: SearchRankDocument
//    var body: some View {
//        VStack {
//            if document.searchRanking.storedSearches.first != nil {
//                #if os(macOS)
//                    NavigationView {
//                        SearchRankDocumentOverview($document)
//                        Text("Select ranking or search in the sidebar to view.")
//                    }
//                #else
//                    SearchRankDocumentOverview($document)
//                #endif
//            } else {
//                SearchingView(searchDoc: $document, searchHostURL: URL(string: SPISearchParser.serverHost)!)
//            }
//        }
//        // Applied to the top level view in a macOS App, this controls both the initial size
//        // of the window that appears and the maximum size to which it can be expanded.
//        .frame(idealWidth: 500, maxWidth: .infinity, idealHeight: 300, maxHeight: .infinity)
//        // in macOS 13+ this can be replaced with the .defaultSize(width: 1000, height: 650)
//        // modifier on the enclosing scene to create a default size experience.
//    }
// }
//
// struct SearchRankEditorView_Previews: PreviewProvider {
//    static func extendedExample() -> SearchRankDocument {
//        var doc = SearchRankDocument(.example)
//        var secondSearch = RecordedSearchResult.example
//        secondSearch.id = UUID()
//        doc.searchRanking.storedSearches.append(secondSearch)
//        doc.searchRanking.relevanceSets.append(RelevanceRecord.example)
//        var secondRanking = RelevanceRecord.example
//        secondRanking.id = UUID()
//        secondRanking.reviewer = "heckj"
//        doc.searchRanking.relevanceSets.append(secondRanking)
//        return doc
//    }
//
//    static var previews: some View {
//        SearchRankEditorView(document: .constant(SearchRankDocument()))
//        SearchRankEditorView(document: .constant(extendedExample()))
//    }
// }
