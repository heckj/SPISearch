//
//  RankingReviewerView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/7/22.
//

import SwiftUI

struct RankingReviewerView: View {
    @AppStorage(SPISearchApp.reviewerKey) var localReviewer: String = ""
    @State var reviewerId: String = ""
    @Binding var ranking: SearchRankDocument

    func relevanceSetBinding() -> Binding<RelevanceRecord>? {
        if let index = ranking.searchRanking.relevanceSets.firstIndex(where: { $0.reviewer == localReviewer }) {
            return Binding(projectedValue: $ranking.searchRanking.relevanceSets[index])
        }
        return nil
    }

    var body: some View {
        if localReviewer.isEmpty {
            Form {
                HStack(alignment: .firstTextBaseline) {
                    Text("Enter your reviewer ID")
                    TextField(text: $reviewerId) {
                        Text("reviewer id")
                    }
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    Button {
                        ranking.searchRanking.addRelevanceSet(for: reviewerId)
                        localReviewer = reviewerId
                    } label: {
                        Text("Submit")
                    }
                }.padding()
            }
        } else {
            VStack {
                Text("Hello \(localReviewer)")
                // Used for debugging the preview
//                Button {
//                    localReviewer = ""
//                } label: {
//                    Text("CLEAR")
//                }
                if let relevanceSet = relevanceSetBinding() {
                    RankingSearchResultsView(
                        ranking: relevanceSet,
                        recordedSearch: ranking.searchRanking.combinedRandomizedSearchResult()
                    )
                }
            }
        }
    }

    init(_ ranking: Binding<SearchRankDocument>) {
        _ranking = ranking
    }
}

struct RankingReviewerView_Previews: PreviewProvider {
    static var previews: some View {
        RankingReviewerView(.constant(SearchRank.extendedExample))
    }
}
