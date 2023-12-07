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
    }

    /// The key used for storing the identity of the reviewer in AppStorage (UserDefaults).
    static var reviewerKey: String = "reviewer"
}
