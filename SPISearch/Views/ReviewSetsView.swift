import SPISearchResult
import SwiftUI

struct ReviewSetsView: View {
    let reviewerID: SearchRank.ReviewerID?
    @Binding var searchrank: SearchRank

    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 230, maximum: .infinity)),
        GridItem(.fixed(18)),
        GridItem(.flexible(maximum: 100)),
    ]

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                if let reviewerID {
                    Text("Reviewer: \(searchrank.nameOfReviewer(reviewerId: reviewerID))")
                    Text("\(reviewerID.uuidString)").font(.caption)

                    ForEach(searchrank.queriesReviewed(by: reviewerID), id: \.self) { queryterm in
                        VStack(alignment: .leading) {
                            Text("Search for: \(queryterm)")
                            LazyVStack(alignment: .leading) {
                                ForEach(searchrank.reviews(by: reviewerID, query: queryterm), id: \.0) { pkgId, relevance in
                                    // key => [(SearchResult.Package.PackageId, Relevance)]
                                    LazyVGrid(columns: columns, alignment: .leading, content: {
                                        Text("\(pkgId.description)")
                                        RelevanceResultView(relevance)
                                        Text("\(relevance.description)")
                                        Button(role: .destructive) {
                                            searchrank.removeReview(by: reviewerID, query: queryterm, id: pkgId)
                                        } label: {
                                            Text("delete")
                                        }

                                    })
                                }
                            }
                        }
                    }
                    Spacer()
                } else {
                    EmptyView()
                } // if-else reviewerId
            } // VStack
            .padding(.horizontal)
        } // ScrollView
        .id(searchrank.hashValue)
    }
}

struct ReviewSetsView_Previews: PreviewProvider {
    static var model: SearchRank {
        SearchRank.exampleWithReviews()
    }

    static var previews: some View {
        ReviewSetsView(reviewerID: model.reviewerNames.keys.first,
                       searchrank: .constant(model))
    }
}
