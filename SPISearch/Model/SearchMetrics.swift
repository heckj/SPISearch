//
//  SearchMetrics.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//

/// A collection of search metrics calculated for a stored search result against a relevance ranking.
struct SearchMetrics {
    /// The precision of the search results.
    ///
    /// The precision of a set of search results is defined as ratio of the number of relevant documents compared to the total number of results retrieved.
    let precision: Double

    /// The recall of the search results.
    ///
    /// The recall of a set of search results is defined as ratio of the number of relevant documents compared to the total number of relevant documents available.
    let recall: Double

    /// The mean reciprocal rank of the search results.
    ///
    /// The mean reciprocal rank is a summed relevance rating for the search results, weighting earlier relevant results higher than later relevant results.
    let meanReciprocalRank: Double

    /// Creates a new set of search metrics from the search result and ranking that you provide.
    /// - Parameters:
    ///   - searchResult: The search results to process.
    ///   - ranking: The rankings used to evaluate the search results.
    init(searchResult: RecordedSearchResult, ranking: RelevanceRecord) {
        precision = SearchMetrics.calculatePrecision(searchResult: searchResult, ranking: ranking)
        recall = SearchMetrics.calculateRecall(searchResult: searchResult, ranking: ranking)
        meanReciprocalRank = SearchMetrics.calculateMeanReciprocalRank(searchResult: searchResult, ranking: ranking)
    }
    
    /// Calculates the precision for a set of search results.
    /// - Parameters:
    ///   - searchResult: The search results to process.
    ///   - ranking: The rankings used to evaluate the search results.
    /// - Returns: A value between `0` and `1` that represents the precision of the search results.
    ///
    /// The precision of a set of search results is defined as ratio of the number of relevant documents compared to the total number of results retrieved.
    static func calculatePrecision(searchResult: RecordedSearchResult, ranking: RelevanceRecord) -> Double {
        #warning("Implement calculatePrecision")
        return 0
    }

    /// Calculates the recall for a set of search results.
    /// - Parameters:
    ///   - searchResult: The search results to process.
    ///   - ranking: The rankings used to evaluate the search results.
    /// - Returns: A value between `0` and `1` that represents the recall of the search results.
    ///
    /// The recall of a set of search results is defined as ratio of the number of relevant documents compared to the total number of relevant documents available.
    static func calculateRecall(searchResult _: RecordedSearchResult, ranking _: RelevanceRecord) -> Double {
        #warning("Implement calculateRecall")
        return 0
    }

    /// Calculates the mean reciprocal rank for a set of search results.
    /// - Parameters:
    ///   - searchResult: The search results to process.
    ///   - ranking: The rankings used to evaluate the search results.
    /// - Returns: A value between `0` and `1` that represents the mean reciprocal rank of the search results.
    ///
    /// The mean reciprocal rank is a summed relevance rating for the search results, weighting earlier relevant results higher than later relevant results.
    static func calculateMeanReciprocalRank(searchResult _: RecordedSearchResult, ranking _: RelevanceRecord) -> Double {
        #warning("Implement calculateMeanReciprocalRank")
        return 0
    }
}
