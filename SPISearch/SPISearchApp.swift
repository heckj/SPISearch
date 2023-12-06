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
        DocumentGroup(newDocument: SearchRankDocument()) { _ in
//            SearchRankEditorView(document: file.$document)
            Text("TOP LEVEL DOCUMENT VIEW")
        }
        #if os(macOS)
            Settings {
                SettingsFormView()
            }
        #endif
        //        #if os(macOS) // macOS 13+ only
        //        .defaultSize(width: 1000, height: 650)
        //        #endif
    }

    /// The key used for storing the identity of the reviwer in AppStorage (UserDefaults).
    static var reviewerKey: String = "reviewer"
}
