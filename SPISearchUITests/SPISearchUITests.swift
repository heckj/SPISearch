//
//  SPISearchUITests.swift
//  SPISearchUITests
//
//  Created by Joseph Heck on 2/1/24.
//

import XCTest

final class SPISearchUITests: XCTestCase {
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // In UI tests it’s important to set the initial state - such as interface orientation
        // - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
        // This method is called after the invocation of each test method in the class.
    }

    @available(macOS 14.0, iOS 17.0, *)
    func testAutomatedAccessibility() {
        // https://holyswift.app/xcode-15-new-feature-streamlined-accessibility-audits/
        let myApp = XCUIApplication()
        myApp.launch()

        do {
            try myApp.performAccessibilityAudit()
        } catch {
            XCTFail("The automated accessibility audit failed due to [\(error.localizedDescription)]")
        }
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
