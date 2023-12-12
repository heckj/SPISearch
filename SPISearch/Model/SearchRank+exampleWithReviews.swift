import Foundation
import SPISearchResult

extension SearchRank {
    static func exampleWithReviews() -> SearchRank {
        let exampleReviewerId = UUID(uuidString: "85176E26-9D9A-41B5-A700-04EB3E5BA502")!
        var searchRank = SearchRank(SearchResult.exampleCollection)

        searchRank.addOrUpdateEvaluator(reviewerId: exampleReviewerId, reviewerName: "Fred")

        let reviewedPackages: [SearchResult.Package.PackageId] = [
            .init(owner: "heckj", repository: "CRDT"),
            .init(owner: "automerge", repository: "automerge-swift"),
            .init(owner: "yorkie-team", repository: "yorkie-ios-sdk"),
            .init(owner: "y-crdt", repository: "yswift"),
            .init(owner: "appdecentral", repository: "replicatingtypes"),
        ]

        for pkgId in reviewedPackages {
            if pkgId.owner == "yorkie-team" {
                searchRank.addOrUpdateRelevanceEvaluation(reviewer: exampleReviewerId, query: "crdt", packageId: pkgId, relevance: .partial)
            } else {
                searchRank.addOrUpdateRelevanceEvaluation(reviewer: exampleReviewerId, query: "crdt", packageId: pkgId, relevance: .relevant)
            }
        }

        return searchRank
    }
}
