//
//  SearchingView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct SearchingView: View {
    @State var searchURL = "/search?query=ping"
    @State var resultSet: SearchResultSet? = nil

    var body: some View {
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
}

struct SearchingView_Previews: PreviewProvider {
    static var previews: some View {
        SearchingView()
    }
}
