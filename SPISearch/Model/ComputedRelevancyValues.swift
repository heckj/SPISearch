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
        print("keywords: \(self.keywords.keys.sorted()) vs \(keywords.sorted())")

        print("pkgIds: \(packages.keys.sorted()) vs \(packageIds.sorted())")
        print("keywords equal? \(self.keywords.keys.sorted() == keywords.sorted())")
        print("packages equal? \(packages.keys.sorted() == packageIds.sorted())")
        return self.keywords.keys.sorted() == keywords.sorted() &&
            packages.keys.sorted() == packageIds.sorted()
    }
}
