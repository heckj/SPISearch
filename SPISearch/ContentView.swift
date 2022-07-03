//
//  ContentView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/2/22.
//

import SwiftSoup
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: SearchingView(searchHostURL: SPISearchParser.hostedURL)) {
                    Text("hosted search")
                }
                NavigationLink(destination: SearchingView(searchHostURL: SPISearchParser.localURL)) {
                    Text("local search")
                }
                NavigationLink(destination: EmptyView()) {
                    Text("compare search")
                }
                NavigationLink(destination: EmptyView()) {
                    Text("relevance")
                }
                Spacer()
            }
            VStack {
                EmptyView()
            }
        }
        // Applied to the top level view in a macOS App, this controls both the initial size
        // of the window that appears and the maximum size to which it can be expanded.
        .frame(idealWidth: 500, maxWidth: .infinity, idealHeight: 300, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(
                .fixed(width: 500, height: 700)
            )
    }
}
