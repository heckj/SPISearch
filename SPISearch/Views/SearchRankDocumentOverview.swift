import OSLog
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
                                // original importer was streamed search results
                                // SearchResultImporter.bestEffort(from: fileURL)
                                for aSearchResult in try ReconstructionEngine.bestEffort(from: fileURL) {
                                    document.searchRanking.searchResultCollection.append(aSearchResult)
                                }
                            } catch {
                                Logger.app.warning("Error importing search results: \(error)")
                            }
                        case let .failure(error):
                            Logger.app.warning("Error attempting to import search results: \(error)")
                        }
                    }
                    Spacer()
                }

                Text("\(document.searchRanking.searchResultCollection.count) search collections")
                Text("\(document.searchRanking.reviewedEvaluationCollections.count) evaluations")
            }
            Section("Searches") {
                ForEach(document.searchRanking.searchResultCollection) { searchResult in
                    #if os(iOS)
                        NavigationLink("\(searchResult.query) on \(searchResult.timestamp.formatted(date: .abbreviated, time: .omitted))", destination: SearchResultView($document.searchRanking, for: searchResult))
                    #elseif os(macOS)
                        NavigationLink("\(searchResult.query) on \(searchResult.timestamp.formatted(date: .abbreviated, time: .omitted))", value: Destination.search(searchResult))
                    #endif
                }
            }
            Section("Evaluations") {
                #if os(iOS)
                    NavigationLink("Evaluate", destination: {
                        EvaluateAvailableSearchResults(searchRankDoc: $document)
                    })
                    ForEach(document.searchRanking.reviewers, id: \.self) { reviewerId in
                        NavigationLink("\(document.searchRanking.nameOfReviewer(reviewerId: reviewerId)) has \(document.searchRanking.reviewedEvaluationCollections[reviewerId]?.count ?? 0) evaluations stored", destination: ReviewSetsView(reviewerID: reviewerId, searchrank: $document.searchRanking))
                    }
                #elseif os(macOS)
                    ForEach(document.searchRanking.reviewers, id: \.self) { reviewerId in
                        NavigationLink("\(document.searchRanking.nameOfReviewer(reviewerId: reviewerId)) has \(document.searchRanking.reviewedEvaluationCollections[reviewerId]?.count ?? 0) evaluations stored", value: Destination.evals(reviewerId))
                    }
                #endif
            }
        }
        .navigationDestination(for: Destination.self, destination: { result in
            switch result {
            case let .search(searchResult):
                SearchResultView($document.searchRanking, for: searchResult)
            case let .evals(reviewerID):
                ReviewSetsView(reviewerID: reviewerID, searchrank: $document.searchRanking)
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                let reviewerID = SPISearchApp.reviewerID()
                let reviewerName = document.searchRanking.reviewerNames[reviewerID] ?? "unknown"
                Text("Reviewer: \(reviewerName) (\(reviewerID))")
            }
            #if os(macOS)
                ToolbarItem(placement: .principal) {
                    Button {
                        print("CLICKING EVALUATE!!")
                        destination = .evaluate
                        // THIS Isn't triggering a switch to an eval view - so on macOS, maybe
                        // we open a new window to run the evaluation with the document
                    } label: {
                        Text("EVAL")
                    }
                }
            #endif
        }
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
