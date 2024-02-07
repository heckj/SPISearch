import SPISearchResult
import SwiftUI

struct SearchResultView: View {
    @Binding var model: SearchRank
    let recordedSearch: SearchResult

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                HStack {
                    Text("query:")
                    HStack {
                        Text(recordedSearch.query)
                            .textSelection(.enabled)
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .opacity(0.5)
                    }
                    .font(.title)
                    .padding(4)
                    .border(.black)
                    Text("**\(recordedSearch.packages.count)** at  \(recordedSearch.timestamp.formatted())")
                        .textSelection(.enabled)
                        .padding(.leading)
                }
                HStack {
                    Spacer()
                    if let metrics = model.medianMetrics(for: recordedSearch) {
                        HStack {
                            Text("Precision: \(metrics.precision.formatted())")
                            Text("NDCG: \(metrics.ndcg.formatted())")
                        }
                    } else {
                        Text("Review is \(model.percentEvaluationComplete(for: recordedSearch, by: SPISearchApp.reviewerID()).formatted(.percent)) percent complete")
                    }
                    Spacer()
                }
                HStack(alignment: .top) {
                    // first the searches
                    LazyVStack(alignment: .leading) {
                        Text("Matching packages")
                            .font(.title2)
                        ForEach(recordedSearch.packages) { package in
                            HStack {
                                SearchResultPackageView(package, keywords: recordedSearch.keywords)
                                    .frame(minWidth: 120, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)

                                RelevanceSelectorView($model, query: recordedSearch.query, for: package).frame(minWidth: 10, maxWidth: 50)
                                    .padding(.trailing)
                            }
                        }
                    }
                    // second the matched keywords
                    VStack(alignment: .leading) {
                        Text("Matching authors")
                            .font(.title2)
                        FlowLayout(spacing: 4) {
                            ForEach(recordedSearch.authors, id: \.self) { word in
                                CapsuleText(word)
                                    .textSelection(.enabled)
                            }
                        }
                        Text("Matching keywords")
                            .font(.title2)
                        FlowLayout(spacing: 4) {
                            ForEach(recordedSearch.keywords, id: \.self) { word in
                                CapsuleText(word)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                }
                Spacer()
            } // VStack
            .padding()
        } // ScrollView
    }

    init(_ model: Binding<SearchRank>, for sr: SearchResult) {
        _model = model
        recordedSearch = sr
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultView(
            .constant(SearchRankDocument(SearchRank.exampleWithReviews()).searchRanking),
            for: SearchResult.exampleCollection[0]
        )
        .background(.thickMaterial)
        SearchResultView(
            .constant(SearchRankDocument(SearchRank.exampleWithReviews()).searchRanking),
            for: SearchResult.exampleCollection[1]
        )
        .background(.thickMaterial)
        SearchResultView(
            .constant(SearchRankDocument(SearchRank.exampleWithReviews()).searchRanking),
            for: SearchResult.exampleCollection[2]
        )
        .background(.thickMaterial)
    }
}
