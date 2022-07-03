//
//  SearchingView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct SearchingView: View {
    let searchHostURL: URL?
    @State var searchURI: String = "/search?query=bezier"
    @State var resultSet: SearchResultSet? = nil

    var body: some View {
        Form {
            TextField("Search", text: $searchURI)
                .onSubmit {
                    Task {
                        resultSet = await SPISearchParser.search(searchURI, at: searchHostURL)
                    }
                }
        }.padding()
        if let resultSet = resultSet {
            SearchResultSetView(resultSet)
                .padding()
        }
        Spacer()
    }

    init(searchHostURL: URL?,
         searchURI: String? = nil)
    {
        self.searchHostURL = searchHostURL
        if let searchURI = searchURI {
            self.searchURI = searchURI
        }
    }
}

struct SearchingView_Previews: PreviewProvider {
    static var previews: some View {
        SearchingView(searchHostURL: SPISearchParser.hostedURL)
    }
}
