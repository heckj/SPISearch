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
    @State var resultSet: SearchResultSet? = nil

    var body: some View {
        VStack {
            Form {
                TextField("Search", text: $searchURL)
                    .onSubmit {
                        Task {
                            resultSet = await SPISearchParser.search(searchURL)
                        }
                    }
            }.padding()
            if let resultSet = resultSet {
                SearchResultSetView(resultSet)
                    .padding()
            }
            Spacer()
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
