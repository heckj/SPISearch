//
//  RelevanceReview.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct RelevanceSelectorView: View {
    @Binding var relevance: Relevance
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
        }
        .padding()
        .frame(maxWidth: 150)
    }

    init(_ relevance: Binding<Relevance>) {
        _relevance = relevance
    }
}

struct RelevanceReview_Previews: PreviewProvider {
    static var previews: some View {
        RelevanceSelectorView(.constant(.partial))
    }
}
