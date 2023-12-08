import Foundation
import SPISearchResult

/// A collection of relevance evaluations for the searches matching a specific set of query terms.
class ReviewSet: Hashable, Codable {
    /// The query terms used for the related searches
    let query_terms: String
    /// A combined set of relevance choices for the packages from all searches matching the query terms.
    var reviews: [SearchResult.Package.PackageId: Relevance]

    init(query_terms: String, reviews: [SearchResult.Package.PackageId: Relevance]) {
        self.query_terms = query_terms
        self.reviews = reviews
    }

    // Conformances

    static func == (lhs: ReviewSet, rhs: ReviewSet) -> Bool {
        lhs.query_terms == rhs.query_terms &&
            lhs.reviews == rhs.reviews
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(query_terms)
        hasher.combine(reviews)
    }
}
