import Foundation
import SPISearchResult

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

    /// The normalized discounted cumulative gain (NDGC) of the search results.
    ///
    /// The [NDGC](https://en.wikipedia.org/wiki/Discounted_cumulative_gain) compares a discounted cumulative gain
    /// against a potentially ideal cumulative gain for a set of results to highlight improvements in ordering that wouldn't otherwise be visible in
    /// search metrics.
    let ndcg: Double

    /// Creates a new set of search metrics from the search result and ranking that you provide.
    ///
    /// The initializer returns `nil` is the rankings are incomplete for the provided search results.
    /// - Parameters:
    ///   - searchResult: The search results to process.
    ///   - ranking: The rankings used to evaluate the search results.
    init?(searchResult: SearchResult, reviews: RelevancyValues) {
        // determine completeness of reviews by checking searchresult.query == computedRelevancy.query
        // and that all packageIds in the search result have a value in RelevancyValues
        if searchResult.query != reviews.query_terms {
            // mismatched searchresult and set of relevancy values
            return nil
        }

        let completelyEvaluated = searchResult.packages.allSatisfy { package in
            reviews.relevanceValue.keys.contains(package.id)
        }

        if !completelyEvaluated {
            return nil
        }

        precision = SearchMetrics.calculatePrecision(searchResult: searchResult, ranking: reviews)
        recall = SearchMetrics.calculateRecall(searchResult: searchResult, ranking: reviews)
        meanReciprocalRank = SearchMetrics.calculateMeanReciprocalRank(searchResult: searchResult, ranking: reviews)
        ndcg = SearchMetrics.calculateNDCG(searchResult: searchResult, ranking: reviews)
    }

    /// Calculates the precision for a set of search results.
    /// - Parameters:
    ///   - searchResult: The search results to process.
    ///   - ranking: The rankings used to evaluate the search results.
    /// - Returns: A value between `0` and `1` that represents the precision of the search results.
    ///
    /// The precision of a set of search results is defined as ratio of the number of relevant documents compared to the total number of results retrieved.
    static func calculatePrecision(searchResult: SearchResult, ranking: RelevancyValues) -> Double {
        let countOfRelevantResults: Double = searchResult.packages.reduce(into: 0) { value, result in
            value = value + (ranking.relevanceValue[result.id] ?? 0.0)
        }
        return countOfRelevantResults / Double(searchResult.packages.count)
    }

    /// Calculates the recall for a set of search results.
    /// - Parameters:
    ///   - searchResult: The search results to process.
    ///   - ranking: The rankings used to evaluate the search results.
    /// - Returns: A value between `0` and `1` that represents the recall of the search results.
    ///
    /// The recall of a set of search results is defined as ratio of the number of relevant documents compared to the total number of relevant documents available.
    static func calculateRecall(searchResult: SearchResult, ranking: RelevancyValues) -> Double {
        let countOfRelevantResults: Double = searchResult.packages.reduce(into: 0) { value, result in
            value = value + (ranking.relevanceValue[result.id] ?? 0.0)
        }
        // Since we don't actively know how many relevant results existed that _weren't_ returned from a search,
        // we'll base this count on the total number of entries in the relevant ranking dictionary.
        // That makes it useful for comparing between search results with a common relevance ranking,
        // where some results might be omitted, but also provides a fairly "invalid" value for any single, arbitrary search.

        // We might look at enhancing this by allowing a relevance dictionary to get manual additions in case there
        // _are_ known relevant documents that we expect to be returned, but aren't.
        return countOfRelevantResults / Double(ranking.relevanceValue.count)
    }

    /// Calculates the mean reciprocal rank for a set of search results.
    /// - Parameters:
    ///   - searchResult: The search results to process.
    ///   - ranking: The rankings used to evaluate the search results.
    /// - Returns: A value between `0` and `1` that represents the mean reciprocal rank of the search results.
    ///
    /// The [mean reciprocal rank](https://en.wikipedia.org/wiki/Mean_reciprocal_rank) is a summed relevance rating for the search results,
    /// weighting earlier relevant results higher than later relevant results.
    static func calculateMeanReciprocalRank(searchResult: SearchResult, ranking: RelevancyValues) -> Double {
        let relevanceValues: [Double] = searchResult.packages.map { result in
            ranking.relevanceValue[result.id] ?? 0.0
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
    static func calculateNDCG(searchResult: SearchResult, ranking: RelevancyValues) -> Double {
        let relevanceValues: [Double] = searchResult.packages.map { result in
            // print("package: \(result.id.description) => ranking.relevanceValue[result.id]")
            ranking.relevanceValue[result.id] ?? 0.0
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
