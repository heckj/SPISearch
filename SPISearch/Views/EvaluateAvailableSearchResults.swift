//
//  EvaluateAvailableSearchResults.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import SPISearchResult
import SwiftUI

struct EvaluateAvailableSearchResults: View {
    @AppStorage(SPISearchApp.reviewerIDKey) var localReviewerId: String = UUID().uuidString
    @AppStorage(SPISearchApp.reviewerNameKey) var localReviewerName: String = ""

    @Binding var document: SearchRankDocument

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
        guard let properId = UUID(uuidString: localReviewerId),
              let packageToEvaluate
        else {
            return
        }
        document.searchRanking.addOrUpdateRelevanceEvaluation(
            reviewer: properId,
            query: packageToEvaluate.query,
            packageId: packageToEvaluate.package.id,
            relevance: relevance
        )
        self.packageToEvaluate = evaluationQueue.popLast()
    }

    var body: some View {
        VStack {
            if let packageToEvaluate {
                Text("Query Terms: \(packageToEvaluate.query)")
                HStack(alignment: .firstTextBaseline) {
                    Text("Keywords:")
                    ForEach(packageToEvaluate.keywords, id: \.self) { word in
                        CapsuleText(word)
                            .textSelection(.enabled)
                            .fixedSize()
                    }
                }
                Divider()

                SearchResultPackageView(packageToEvaluate.package, keywords: packageToEvaluate.keywords)
                    .padding(.horizontal)

                Divider()
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
