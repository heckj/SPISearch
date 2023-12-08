import Foundation
import SPISearchResult

/// A collection of relevance evaluations for the searches matching a specific set of query terms.
struct ReviewSet: Hashable, Codable {
    /// The query terms used for the related searches
    let query_terms: String
    /// A combined set of relevance choices for the packages from all searches matching the query terms.
    var reviews: [SearchResult.Package.PackageId: Relevance]
}

/// A collection of the reviews by a reviewer.
struct RelevanceEvaluation: Hashable, Identifiable, Codable {
    /// The review providing the relevance evaluations
    var id: UUID

    /// The evaluations provided by the reviewer.
    var rankings: [ReviewSet] // set?

    init(reviewer: UUID, rankings: [ReviewSet] = []) {
        id = reviewer
        self.rankings = rankings
    }
}
