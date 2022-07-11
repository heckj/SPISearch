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

    init() {
        #if os(macOS)
            let info = ProcessInfo.processInfo
            print("fullusername: \(info.fullUserName)")
            print("userid: \(info.userName)")
            print("arguments to app \(info.arguments)")
            do {
                let args = try SPISearchLaunchArguments.parse()
                print("args: \(args)")

                // App store apps suggest to NEVER do this:
                // exit(0)

            } catch {
                print("Error: Could not parse arguments")
                print(CommandLine.arguments.dropFirst().joined(separator: " "))
                print(SPISearchLaunchArguments.helpMessage())
            }
        #endif
    }

    /// The key used for storing the identity of the reviwer in AppStorage (UserDefaults).
    static var reviewerKey: String = "reviewer"
}
