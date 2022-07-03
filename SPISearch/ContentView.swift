//
//  ContentView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/2/22.
//

import SwiftSoup
import SwiftUI

struct ContentView: View {
    @State var searchURL = "https://swiftpackageindex.com/search?query=bezier"
    @State var err: Bool = false
    @State var errmsg: String = ""

    @State var searchresults: [PackageSearchResult] = []
    @State var matchedKeywords: [String] = []

    var body: some View {
        VStack {
            Form {
                TextField("Search", text: $searchURL)
                    .onSubmit {
                        Task {
                            self.err = false
                            await loadData(searchURL)
                        }
                    }
                if err {
                    // Display any error messages in red
                    Text(errmsg)
                        .foregroundColor(.red)
                }
            }.padding()
            List(searchresults) { result in
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(result.name)
                            .font(.title)
                        ForEach(result.keywords, id: \.self) { word in
                            CapsuleText(word)
                        }
                    }
                    Text(result.summary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Divider()
            }
        }
        // Applied to the top level view in a macOS App, this controls both the initial size
        // of the window that appears and the maximum size to which it can be expanded.
        .frame(idealWidth: 500, maxWidth: .infinity, idealHeight: 300, maxHeight: .infinity)
    }

    func loadData(_ url: String) async {
        guard let url = URL(string: url) else {
            // print("Invalid URL")
            errmsg = "Invalid URL"
            err = true
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            // more code to come
            if let httpresponse = response as? HTTPURLResponse {
                if httpresponse.statusCode != 200 {
                    err = true
                    errmsg = httpresponse.debugDescription
                }
            }
            let HTMLString = String(data: data, encoding: .utf8)!
            let results = try await SPISearchParser.parse(HTMLString)
            searchresults = results.results
            matchedKeywords = results.matched_keywords
        } catch {
            if let urlerr = error as? URLError {
                // print("URLError")
                // print("unavailableReason: \(String(describing: urlerr.networkUnavailableReason))")
                // print("errorCode: \(String(describing: urlerr.errorCode))")
                // print("localizedDescription: \(String(describing: urlerr.localizedDescription))")
                // print("backgroundTaskCancelledReason: \(String(describing: urlerr.backgroundTaskCancelledReason))")
                // print("failureURLString: \(String(describing: urlerr.failureURLString))")
                err = true
                errmsg = "\(urlerr.localizedDescription)"
            } else {
                // print("Invalid data")
                err = true
                errmsg = "Invalid data \(error)"
            }
        }
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
