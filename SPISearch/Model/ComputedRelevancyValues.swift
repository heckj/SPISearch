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

    func isComplete(keywords: [String], packageIDs: [String]) -> Bool {
        // we don't care if they're equal, only that the keywords and packages
        // are contained within the set that we have recorded.
        let allKeywordsAccounted = keywords.allSatisfy { keyword_to_check in
            self.keywords.keys.contains(keyword_to_check)
        }
        let allPackagesAccounted = packageIDs.allSatisfy { pkgID_to_check in
            self.packages.keys.contains(pkgID_to_check)
        }
        return allKeywordsAccounted && allPackagesAccounted
    }
}
