import SPISearchResult
import SwiftUI

struct EvaluateAvailableSearchResults: View {
    @Binding var document: SearchRankDocument
    let localReviewerId = SPISearchApp.reviewerID()

    @State private var queueCount: Int = 0
    @State private var evaluationQueue: [PackageToEvaluate] = []
    @State private var packageToEvaluate: PackageToEvaluate?

    func highlightColor(_ relevance: Relevance) -> Color {
        switch relevance {
        case .unknown:
            return .yellow.opacity(0.5)
        case .not:
            return .gray.opacity(0.1)
        case .partial:
            return .green.opacity(0.2)
        case .relevant:
            return .green.opacity(0.5)
        }
    }

    func updateRelevanceAndAdvance(_ relevance: Relevance) {
        guard let packageToEvaluate else {
            return
        }
        document.searchRanking.addOrUpdateRelevanceEvaluation(
            reviewer: localReviewerId,
            query: packageToEvaluate.query,
            packageId: packageToEvaluate.package.id,
            relevance: relevance
        )
        self.packageToEvaluate = evaluationQueue.popLast()
    }

    var body: some View {
        VStack {
            if let packageToEvaluate {
                Text("Reviewer ID: \(localReviewerId)")
                Text("Query Terms: \(packageToEvaluate.query)")
                HStack {
                    Text("Keywords:")
                    OverflowGrid(horizontalSpacing: 4) {
                        ForEach(packageToEvaluate.keywords, id: \.self) { word in
                            CapsuleText(word)
                                .textSelection(.enabled)
                        }
                    }
                }
                Divider()

                SearchResultPackageView(packageToEvaluate.package, keywords: packageToEvaluate.keywords)
                    .padding(.horizontal)

                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        updateRelevanceAndAdvance(.not)
                    }, label: {
                        Image(systemName: "hand.thumbsdown")
                            .font(.title)
                    })
                    Spacer()
                    Button(action: {
                        updateRelevanceAndAdvance(.partial)
                    }, label: {
                        Image(systemName: "minus.square")
                            .font(.title)
                    })
                    Spacer()
                    Button(action: {
                        updateRelevanceAndAdvance(.relevant)
                    }, label: {
                        Image(systemName: "hand.thumbsup")
                            .font(.title)
                    })
                    Spacer()
                }
                .padding(.vertical)
                .border(.blue)
                .padding(.horizontal)
            } else {
                Text("No search results to be reviewed")
            }
        }
        .onAppear(perform: {
            evaluationQueue = document.searchRanking.queueOfReviews(reviewerId: localReviewerId)
            queueCount = evaluationQueue.count
            packageToEvaluate = evaluationQueue.popLast()
        })
    }

    init(searchRankDoc: Binding<SearchRankDocument>) {
        _document = searchRankDoc
    }
}

struct RankingSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        EvaluateAvailableSearchResults(
            searchRankDoc: .constant(SearchRankDocument(SearchResult.exampleCollection))
        )
    }
}
