import Foundation
import SwiftUI

/// The cross-platform document-based utility application.
@main
struct SPISearchApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: SearchRankDocument()) { fileconfig in
            SearchRankEditorView(document: fileconfig.$document)
        }
        #if os(macOS)
            Settings {
                SettingsFormView()
            }
//        WindowGroup(id: "eval", for: SearchRank) { document in
//            EvaluateAvailableSearchResults(searchRankDoc: document)
//        }

        #endif
        //        #if os(macOS) // macOS 13+ only
        //        .defaultSize(width: 1000, height: 650)
        //        #endif
    }

    /// The key used for storing the identity of the reviewer in AppStorage (UserDefaults).
    static let reviewerIDKey: String = "reviewerId"
    static let reviewerNameKey: String = "reviewerName"

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
