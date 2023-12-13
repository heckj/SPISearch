//
//  RelevanceRecord.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//
import Foundation
import SPISearchResult

/// A type that indicates the perceived relevance of a search result.
enum Relevance: Int, CaseIterable, Identifiable, Codable, CustomStringConvertible {
    /// Unknown relevancy - not recorded.
    case unknown = -1
    /// Evaluation result of not relevant.
    case not = 0
    /// Evaluation result of partial relevance.
    case partial = 1
    /// Evaluation result of full relevance.
    case relevant = 2

    var id: Self { self }

    /// Returns a numerical relevance value
    /// - Parameter binary: A Boolean value indicating the numerical value should be strictly binary (relevant or not).
    /// - Returns: A value between 0.0 and 1.0 indicating the numerical relevancy score.
    func relevanceValue(binary: Bool = false) -> Double {
        if binary {
            switch self {
            case .relevant, .partial:
                return 1
            default:
                return 0
            }
        } else {
            switch self {
            case .relevant:
                return 1
            case .partial:
                return 0.5
            default:
                return 0
            }
        }
    }

    /// The description of the relevance.
    var description: String {
        switch self {
        case .relevant:
            return "relevant"
        case .partial:
            return "partially relevant"
        case .unknown:
            return "not reviewed"
        case .not:
            return "not relevant"
        }
    }
}
