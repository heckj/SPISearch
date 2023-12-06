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
    /// An opaque identifier of the reviewers rankings
    var id: UUID

    /// The review providing the relevance evaluations
    let reviewer: Reviewer

    /// The evaluations provided by the reviewer.
    var rankings: [ReviewSet] // set?
    
    init(reviewer: Reviewer, rankings: [ReviewSet] = []) {
        id = UUID()
        self.reviewer = reviewer
        self.rankings = rankings
    }
}

/// The reviewer of search results for relevance
struct Reviewer: Hashable, Identifiable, Codable {
    /// The unique identifier for the reviewer
    let id: UUID

    /// The display name for the reviewer/
    var name: String

    /// Creates a new reviewer with the name you provide.
    /// - Parameter name: The name of the reviewer.
    init(name: String) {
        id = UUID()
        self.name = name
    }
}
