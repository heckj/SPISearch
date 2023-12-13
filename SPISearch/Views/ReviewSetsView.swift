import SPISearchResult
import SwiftUI

struct ReviewSetsView: View {
    let reviewerID: SearchRank.ReviewerID?
    let searchrank: SearchRank

    var body: some View {
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
                                HStack {
                                    Text("\(pkgId.description)")
                                    RelevanceResultView(relevance)
                                    Text("\(relevance.description)")
                                }
                            }
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }.padding(.horizontal)
    }
}

struct ReviewSetsView_Previews: PreviewProvider {
    static var model: SearchRank {
        SearchRank.exampleWithReviews()
    }

    static var previews: some View {
        NavigationView {
            VStack {
                ReviewSetsView(reviewerID: model.reviewerNames.keys.first,
                               searchrank: model)
            }
        }
    }
}
