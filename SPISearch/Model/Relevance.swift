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
    case unknown = -1
    case not = 0
    case partial = 1
    case relevant = 2

    var id: Self { self }

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
