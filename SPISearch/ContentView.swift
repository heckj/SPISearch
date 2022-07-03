//
//  ContentView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/2/22.
//

import SwiftSoup
import SwiftUI

struct ContentView: View {
    @State var searchURL = "https://swiftpackageindex.com/search?query=ping"
    @State var err: Bool = false
    @State var errmsg: String = ""

    @State var resultSet: SearchResult? = nil

    var body: some View {
        VStack {
            Form {
                TextField("Search", text: $searchURL)
                    .onSubmit {
                        Task {
                            self.err = false
                            resultSet = await SPISearchParser.search(searchURL)
                        }
                    }
                if err {
                    // Display any error messages in red
                    Text(errmsg)
                        .foregroundColor(.red)
                }
            }.padding()
            if let resultSet = resultSet {
                SearchResultsView(resultSet)
                    .padding()
            } else {
                Spacer()
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
