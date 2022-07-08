//
//  MedianRelevancyTests.swift
//  SPISearchTests
//
//  Created by Joseph Heck on 7/8/22.
//

@testable import SPISearch
import XCTest

final class MedianRelevancyTests: XCTestCase {
    var rank = SearchRank()
    override func setUpWithError() throws {
        var record1 = RelevanceRecord("testcode")
        record1.keywords["first"] = .relevant
        record1.keywords["second"] = .partial
        record1.keywords["third"] = .no
        record1.keywords["fourth"] = .unknown

        record1.packages["packageA"] = .unknown
        record1.packages["packageB"] = .relevant
        record1.packages["packageC"] = .partial
        record1.packages["packageD"] = .no
        record1.packages["packageE"] = .unknown

        var record2 = RelevanceRecord("testcode")
        record2.keywords["first"] = .unknown
        record2.keywords["second"] = .relevant
        record2.keywords["third"] = .partial
        record2.keywords["fourth"] = .no

        record1.packages["packageA"] = .unknown
        record1.packages["packageB"] = .relevant
        record1.packages["packageC"] = .partial
        record1.packages["packageD"] = .no
        record1.packages["packageE"] = .relevant

        rank.relevanceSets.append(record1)
        rank.relevanceSets.append(record2)
    }

    func testExample() throws {
        let computed = rank.medianRelevancyRanking
        XCTAssertNotNil(computed)

        XCTAssertEqual(computed!.keywords["first"], 1.0)
        XCTAssertEqual(computed!.keywords["second"], 0.75)
        XCTAssertEqual(computed!.keywords["third"], 0.25)
        XCTAssertEqual(computed!.keywords["fourth"], 0)

        XCTAssertNil(computed!.packages["packageA"])
        XCTAssertEqual(computed!.packages["packageB"], 1.0)
        XCTAssertEqual(computed!.packages["packageC"], 0.5)
        XCTAssertEqual(computed!.packages["packageD"], 0.0)
        XCTAssertEqual(computed!.packages["packageE"], 1.0)
    }
}
