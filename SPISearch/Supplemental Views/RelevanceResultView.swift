//
//  RelevanceResultView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/10/22.
//

import SwiftUI

struct RelevanceResultView: View {
    let relevance: Relevance
    let withLabel: Bool
    var body: some View {
        VStack {
            switch relevance {
            case .unknown:
                Image(systemName: "questionmark")
            case .relevant:
                Image(systemName: "hand.thumbsup")
            case .partial:
                Image(systemName: "minus.diamond")
            case .no:
                Image(systemName: "hand.thumbsdown")
            }
            if withLabel {
                switch relevance {
                case .unknown:
                    Text("undecided relevance")
                case .relevant:
                    Text("relevant")
                case .partial:
                    Text("partially relevant")
                case .no:
                    Text("not relevant")
                }
            }
        }
        #if os(macOS)
        // macOS shows the title of the picker, while iOS
        // doesn't, which is kind of weird.
        .frame(maxWidth: 170)
        #endif
    }

    init(_ relevance: Relevance, withLabel: Bool = false) {
        self.relevance = relevance
        self.withLabel = withLabel
    }
}

struct RelevanceResultView_Previews: PreviewProvider {
    static var previews: some View {
        RelevanceResultView(.partial)
        RelevanceResultView(.partial, withLabel: true)
    }
}
