//
//  RelevanceSelectorView.swift
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
                Picker("rank", selection: $relevance) {
                    Image(systemName: "hand.thumbsdown").tag(Relevance.no)
                    Image(systemName: "minus.diamond").tag(Relevance.partial)
                    Image(systemName: "hand.thumbsup").tag(Relevance.relevant)
                }
                .pickerStyle(.segmented)
            }
        }
        .padding()
        #if os(macOS)
            // macOS shows the title of the picker, while iOS
            // doesn't, which is kind of weird.
            .frame(maxWidth: 170)
        #else
            .frame(maxWidth: 150)
        #endif
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
