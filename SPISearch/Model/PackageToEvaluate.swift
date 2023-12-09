import SPISearchResult

/// A collection of the details needed to evaluate the relevancy of a package to a given search query
struct PackageToEvaluate {
    /// The search query.
    let query: String
    /// The keywords that match the query string.
    let keywords: [String]
    /// The package from a search result.
    let package: SearchResult.Package

    /// Creates a new instance of a package to evaluate for search relevancy.
    /// - Parameters:
    ///   - query: The search query.
    ///   - keywords: The keywords that match the query string.
    ///   - package: The package from a search result.
    init(query: String, keywords: [String], package: SearchResult.Package) {
        self.query = query
        self.keywords = keywords
        self.package = package
    }
}
