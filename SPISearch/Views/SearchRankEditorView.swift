import SPISearchResult
import SwiftUI

/// The primary document editor view.
struct SearchRankEditorView: View {
    @Binding var document: SearchRankDocument

    var body: some View {
        #if os(macOS)
            NavigationSplitView {
                SearchRankDocumentOverview($document)
            } detail: {
                Text("Select ranking or search in the sidebar to view.")
            }
            .frame(idealWidth: 500, maxWidth: .infinity, idealHeight: 300, maxHeight: 1500)
        // Applied to the top level view in a macOS App, this controls both the initial size
        // of the window that appears and the maximum size to which it can be expanded.
        // in macOS 13+ this can be replaced with the .defaultSize(width: 1000, height: 650)
        // modifier on the enclosing scene to create a default size experience.
        #else
            SearchRankDocumentOverview($document)
        #endif
    }
}

struct SearchRankEditorView_Previews: PreviewProvider {
    static var previews: some View {
        SearchRankEditorView(document: .constant(SearchRankDocument()))
        SearchRankEditorView(document: .constant(SearchRankDocument(SearchResult.exampleCollection)))
    }
}
