//
//  RelevanceReview.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct RelevanceReview: View {
    @State var relevance: Relevance = .unknown
    @State var notes: String = ""
    var body: some View {
        VStack {
            HStack {
                Picker("Relevance", selection: $relevance) {
                    Image(systemName: "hand.thumbsdown").tag(Relevance.no)
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
