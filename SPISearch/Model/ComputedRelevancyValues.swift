//
//  ComputedRelevancyValues.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/8/22.
//

/// A type that holds the average relevancy values computed from the stored rankings in the document.
struct ComputedRelevancyValues {
    var packages: [String: Double] = [:]
    var keywords: [String: Double] = [:]

    func isComplete(keywords: [String], packageIds: [String]) -> Bool {
        self.keywords.keys.sorted() == keywords.sorted() &&
            packages.keys.sorted() == packageIds.sorted()
    }
}
