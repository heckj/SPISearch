//
//  SPISearchApp.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/2/22.
//

import SwiftUI

/// The cross-platform document-based utility application.
@main
struct SPISearchApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: SearchRankDocument()) { file in
            SearchRankEditorView(ranking: file.$document)
        }
        //        #if os(macOS) // macOS 13+ only
        //        .defaultSize(width: 1000, height: 650)
        //        #endif
    }
}
