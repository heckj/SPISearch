import SPISearchResult
import SwiftUI
import SwiftUINavigation

// nav docs: https://pointfreeco.github.io/swiftui-navigation/main/documentation/swiftuinavigation/navigation/
// nav example: https://github.com/pointfreeco/swiftui-navigation/blob/main/Examples/Inventory/Inventory.swift

struct SearchRankDocumentOverview: View {
    @Binding var document: SearchRankDocument

    @State private var importerEnabled = false
    @State private var configureReviewerSheetShown = false
    @State private var destination: Destination?

    enum Destination: Hashable {
        case search(SearchResult)
        case evals(SearchRank.ReviewerID)
        case evaluate
    }

    var body: some View {
        List {
            // #if DEBUG
            //    #if os(macOS)
            //            let _ = Self._printChanges()
            //    #endif
            // #endif
            Section("Summary") {
                // only display import on an empty document?
                if document.searchRanking.searchResultCollection.isEmpty {
                    HStack {
                        Spacer()
                        Button {
                            importerEnabled = true
                        } label: {
                            Label("Import", systemImage: "square.and.arrow.down.on.square")
                        }
                        .fileImporter(isPresented: $importerEnabled, allowedContentTypes: [.text]) { result in
                            switch result {
                            case let .success(fileURL):
                                do {
                                    for aSearchResult in try SearchResultImporter.bestEffort(from: fileURL) {
                                        document.searchRanking.searchResultCollection.append(aSearchResult)
                                    }
                                } catch {
                                    logger.warning("Error importing search results: \(error)")
                                }
                            case let .failure(error):
                                logger.warning("Error attempting to import search results: \(error)")
                            }
                        }
                        Spacer()
                    }
                } else {
                    Text("\(document.searchRanking.searchResultCollection.count) search collections")
                    Text("\(document.searchRanking.reviewedEvaluationCollections.count) evaluations")
                }
            }
            Section("Searches") {
                ForEach(document.searchRanking.searchResultCollection) { searchResult in
                    NavigationLink("\(searchResult.query) on \(searchResult.timestamp.formatted(date: .abbreviated, time: .omitted))", value: Destination.search(searchResult))
                }
            }
            Section("Evaluations") {
                Button(action: {
                    destination = .evaluate
                }, label: {
                    Text("Evaluate")
                })
//                #if os(iOS)
//                    // Well - this doesn't work at all on macOS due to rendering issues with (deprecated) NavigationView
//                    NavigationLink("Evaluate", destination: {
//                        EvaluateAvailableSearchResults(searchRankDoc: $document)
//                    })
//                #endif
                ForEach(document.searchRanking.reviewers, id: \.self) { reviewerId in
                    NavigationLink("\(document.searchRanking.nameOfReviewer(reviewerId: reviewerId)) has \(document.searchRanking.reviewedEvaluationCollections[reviewerId]?.count ?? 0) evaluations stored", value: Destination.evals(reviewerId))
                }
            }
            Spacer()
        }
        .navigationDestination(for: Destination.self, destination: { result in
            switch result {
            case let .search(searchResult):
                SearchResultView($document.searchRanking, for: searchResult)
            case let .evals(reviewerID):
                ReviewSetsView(reviewerID: reviewerID, searchrank: document.searchRanking)
            case .evaluate:
                EvaluateAvailableSearchResults(searchRankDoc: $document)
            }
        })
        #if os(macOS)
        .listStyle(.sidebar)
        #endif
        .sheet(isPresented: $configureReviewerSheetShown) {
            ConfigureReviewer(document: $document)
        }
        .onAppear(perform: {
            // On document open, if there's a set reviewer name, update the document (if needed)
            // to make sure its current.
            let reviewerID = SPISearchApp.reviewerID()
            if document.searchRanking.reviewerNames[reviewerID] == nil {
                // If the reviewer name _isn't_ yet set, then get in their face and get a name
                configureReviewerSheetShown = true
            }
        })
    }

    init(_ document: Binding<SearchRankDocument>) {
        _document = document
    }
}

struct SearchRankDocumentOverview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchRankDocumentOverview(
                .constant(SearchRankDocument(SearchRank.exampleWithReviews()))
            )
        }
    }
}
