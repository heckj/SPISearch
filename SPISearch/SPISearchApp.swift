//
//  SPISearchApp.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/2/22.
//

import SwiftUI

@main
struct SPISearchApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: SearchRankDocument()) { file in
            SearchRankEditorView(ranking: file.$document)
        }
    }
}
