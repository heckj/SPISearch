//
//  SPISearchApp.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/2/22.
//

import Foundation
import SwiftUI

/// The cross-platform document-based utility application.
@main
struct SPISearchApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: SearchRankDocument()) { file in
            SearchRankEditorView(document: file.$document)
        }
        #if os(macOS)
            Settings {
                SettingsFormView()
            }
        #endif
        //        #if os(macOS) // macOS 13+ only
        //        .defaultSize(width: 1000, height: 650)
        //        #endif

//        WindowGroup(id: "eval", for: SearchRank) { searchrank in
//            EvaluateAvailableSearchResults(searchRankDoc: searchrank)
//        }
    }

    /// The key used for storing the identity of the reviewer in AppStorage (UserDefaults).
    static var reviewerIDKey: String = "reviewerId"
    static var reviewerNameKey: String = "reviewerName"

    /// Returns a reviewer identifier.
    /// - Returns: The UUID that represents this reviewer
    ///
    /// The reviewer ID is a randomly generated UUID, stored in UserDefaults for future runs or working with other documents.
    static func reviewerID() -> UUID {
        if let reviewerString = UserDefaults.standard.string(forKey: SPISearchApp.reviewerIDKey),
           let reviewerID = UUID(uuidString: reviewerString)
        {
            return reviewerID
        } else {
            let newID = UUID()
            UserDefaults.standard.set(newID.uuidString, forKey: SPISearchApp.reviewerIDKey)
            return newID
        }
    }
}
