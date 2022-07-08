//
//  SearchMetrics.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/6/22.
//
import Foundation

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
        let countOfRelevantResults: Double = searchResult.resultSet.results.reduce(into: 0) { value, result in
            value = value + ranking.package_relevance(result.id).relevanceValue()
        }
        return countOfRelevantResults / Double(searchResult.resultSet.results.count)
    }

    /// Calculates the recall for a set of search results.
    /// - Parameters:
    ///   - searchResult: The search results to process.
    ///   - ranking: The rankings used to evaluate the search results.
    /// - Returns: A value between `0` and `1` that represents the recall of the search results.
    ///
    /// The recall of a set of search results is defined as ratio of the number of relevant documents compared to the total number of relevant documents available.
    static func calculateRecall(searchResult: RecordedSearchResult, ranking: RelevanceRecord) -> Double {
        let countOfRelevantResults: Double = searchResult.resultSet.results.reduce(into: 0) { value, result in
            value = value + ranking.package_relevance(result.id).relevanceValue()
        }
        // Since we don't actively know how many relevant results existed that _weren't_ returned from a search,
        // we'll base this count on the total number of entries in the relevant ranking dictionary.
        // That makes it useful for comparing between search results with a common relevance ranking,
        // where some results might be omitted, but also provides a fairly "invalid" value for any single, arbitrary search.

        // We might look at enhancing this by allowing a relevance dictionary to get manual additions in case there
        // _are_ known relevant documents that we expect to be returned, but aren't.
        return countOfRelevantResults / Double(ranking._ratings.count)
    }

    /// Calculates the mean reciprocal rank for a set of search results.
    /// - Parameters:
    ///   - searchResult: The search results to process.
    ///   - ranking: The rankings used to evaluate the search results.
    /// - Returns: A value between `0` and `1` that represents the mean reciprocal rank of the search results.
    ///
    /// The [mean reciprocal rank](https://en.wikipedia.org/wiki/Mean_reciprocal_rank) is a summed relevance rating for the search results,
    /// weighting earlier relevant results higher than later relevant results.
    static func calculateMeanReciprocalRank(searchResult: RecordedSearchResult, ranking: RelevanceRecord) -> Double {
        let relevanceValues: [Double] = searchResult.resultSet.results.map { result in
            ranking.package_relevance(result.id).relevanceValue()
        }
        if let firstRelevantResultPosition = relevanceValues.firstIndex(of: 1.0) {
            return 1.0 / Double(firstRelevantResultPosition + 1)
        } else if let firstPartialRelevantResultPosition = relevanceValues.firstIndex(of: 1.0) {
            return 0.5 / Double(firstPartialRelevantResultPosition + 1)
        }
        return 0
    }

    // https://blog.thedigitalgroup.com/measuring-search-relevance-using-ndcg
    // https://medium.com/@_init_/notes-on-the-ndcg-metric-used-in-the-visual-dialog-challenge-2019-90cf443b93dc
    // (Normalized Discounted Cumulative Gain)
    // Cumulative Gain = sum of the relevance values
    // Discounted Cumulative Gain = sum of the relevance value / log(index pos + 1)
    // https://arxiv.org/pdf/1302.2318.pdf (On Search Engine Evaluation Metrics)
    // pg 87 discusses NDCG and various discount values

    /// Calculates the normalized discounted cumulative gain (NDGC) for a set of search results.
    /// - Parameters:
    ///   - searchResult: The search results to process.
    ///   - ranking: The rankings used to evaluate the search results.
    /// - Returns: A value between `0` and `1` that represents the normalized discounted cumulative relevance gain of the search results.
    ///
    /// The [NDGC](https://en.wikipedia.org/wiki/Discounted_cumulative_gain) compares a discounted cumulative gain
    /// against a potentially ideal cumulative gain for a set of results to highlight improvements in ordering that wouldn't otherwise be visible in
    /// search metrics.
    static func calculateNDCG(searchResult: RecordedSearchResult, ranking: RelevanceRecord) -> Double {
        let relevanceValues: [Double] = searchResult.resultSet.results.map { result in
            ranking.package_relevance(result.id).relevanceValue()
        }
        let dcg = relevanceValues.enumerated()
            .map { indexPosition, value in
                // print("+ \(value)/log(\(indexPosition + 2))")
                // return the reciprocal value
                value / log(Double(indexPosition + 2))
            }
            .reduce(into: 0) { partialResult, reciprocalValue in
                partialResult += reciprocalValue
            }
        let idealDCG = relevanceValues.sorted(by: >).enumerated()
            .map { indexPosition, value in
                // print("+ \(value)/log(\(indexPosition + 2))")
                // return the reciprocal value
                value / log(Double(indexPosition + 2))
            }
            .reduce(into: 0) { partialResult, reciprocalValue in
                partialResult += reciprocalValue
            }
        return dcg / idealDCG
    }
}
