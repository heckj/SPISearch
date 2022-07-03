//
//  RelevanceReview.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

enum Relevance: Int, CaseIterable, Identifiable {
    case unknown = -1
    case none = 0
    case partial = 1
    case relevant = 2
    var id: Self { self }
}

struct RelevanceReview: View {
    @State var relevance: Relevance = .unknown
    @State var notes: String = ""
    var body: some View {
        VStack {
            HStack {
                Picker("Relevance", selection: $relevance) {
                    Image(systemName: "hand.thumbsdown").tag(Relevance.none)
                    Image(systemName: "questionmark").tag(Relevance.partial)
                    Image(systemName: "hand.thumbsup").tag(Relevance.relevant)
                }
                .pickerStyle(.segmented)
            }
            TextField("Notes", text: $notes)
        }
        .padding()
    }
}

struct RelevanceReview_Previews: PreviewProvider {
    static var previews: some View {
        RelevanceReview()
            .frame(width: 200)
    }
}
