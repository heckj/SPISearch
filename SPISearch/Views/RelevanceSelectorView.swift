import SPISearchResult
import SwiftUI

struct RelevanceSelectorView: View {
    @Binding var model: SearchRank
    let query: String
    let package: SearchResult.Package

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

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(minimum: 10, maximum: 30))], spacing: 6, content: {
            Button(action: {
                model.addOrUpdateRelevanceEvaluation(reviewer: SPISearchApp.reviewerID(),
                                                     query: query,
                                                     packageId: package.id,
                                                     relevance: .relevant)
            }, label: {
                Image(systemName: "hand.thumbsup")
            })

            Button(action: {
                model.addOrUpdateRelevanceEvaluation(reviewer: SPISearchApp.reviewerID(),
                                                     query: query,
                                                     packageId: package.id,
                                                     relevance: .partial)
            }, label: {
                Image(systemName: "minus.square")
            })

            Button(action: {
                model.addOrUpdateRelevanceEvaluation(reviewer: SPISearchApp.reviewerID(),
                                                     query: query,
                                                     packageId: package.id,
                                                     relevance: .not)
            }, label: {
                Image(systemName: "hand.thumbsdown")
            })

        })
        .buttonStyle(.borderless)
        .font(.title)
    }

    init(_ model: Binding<SearchRank>, query: String, for package: SearchResult.Package) {
        _model = model
        self.query = query
        self.package = package
    }
}

struct RelevanceReview_Previews: PreviewProvider {
    static var previews: some View {
        RelevanceSelectorView(
            .constant(SearchRankDocument(SearchRank.exampleWithReviews()).searchRanking),
            query: "crdt",
            for: SearchRank.exampleWithReviews().searchResultCollection[0].packages[0]
        )
    }
}
