//
//  SearchRankDocument.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var SPISearchRank: UTType {
        UTType(exportedAs: "com.github.heckj.SPISearch.searchrank", conformingTo: .json)
    }
}

struct SearchRankDocument: FileDocument {
    var text: String

    init(text: String = "Hello, world!") {
        self.text = text
    }

    static var readableContentTypes: [UTType] { [.json] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string

        /*
         guard let data = configuration.file.regularFileContents
             else {
                 throw CocoaError(.fileReadCorruptFile)
             }
             self.checklist = try JSONDecoder().decode(Checklist.self, from: data)
         */
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
        /*
         let data = try JSONEncoder().encode(snapshot)
             let fileWrapper = FileWrapper(regularFileWithContents: data)
             return fileWrapper
         */
    }
}
