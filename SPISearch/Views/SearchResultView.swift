import SPISearchResult
import SwiftUI

struct SearchResultView: View {
    @Binding var model: SearchRank
    let recordedSearch: SearchResult

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("**\(recordedSearch.packages.count)** results recorded  \(recordedSearch.timestamp.formatted())")
                    .textSelection(.enabled)
            }

            Form {
                Section("Query") {
                    Text(recordedSearch.query)
                }
                Section("Score") {
                    if let metrics = model.medianMetrics(for: recordedSearch) {
                        HStack {
                            Text("Precision: \(metrics.precision.formatted())")
                            Text("NDCG: \(metrics.ndcg.formatted())")
                        }
                    } else {
                        Text("Review is \(model.percentEvaluationComplete(for: recordedSearch, by: SPISearchApp.reviewerID()).formatted(.percent)) percent complete")
                    }
                }
                Section("Matched Keywords") {
                    FlowLayout(spacing: 4) {
                        ForEach(recordedSearch.keywords, id: \.self) { word in
                            CapsuleText(word)
                                .textSelection(.enabled)
                        }
                    }
                }
                Section("\(recordedSearch.packages.count) Packages") {
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
            }
        }
        .padding()
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
        SearchResultView(
            .constant(SearchRankDocument(SearchRank.exampleWithReviews()).searchRanking),
            for: SearchResult.exampleCollection[1]
        )
        SearchResultView(
            .constant(SearchRankDocument(SearchRank.exampleWithReviews()).searchRanking),
            for: SearchResult.exampleCollection[2]
        )
    }
}
