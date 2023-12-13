import SPISearchResult

/// A type that holds the average relevancy values computed from the stored rankings in the document.
struct RelevancyValues: Hashable {
    /// The query terms used for the related searches
    let query_terms: String
    /// A combined set of relevance choices for the packages from all searches matching the query terms.
    var relevanceValue: [SearchResult.Package.PackageId: Double]
}
