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

    @State var titleString: String = ""
    var body: some View {
        VStack {
            HStack {
                TextField("search", text: $searchURL)
                    .onSubmit {
                        Task {
                            self.err = false
                            await loadData(searchURL)
                        }
                    }
                Button {
                    Task {
                        self.err = false
                        await loadData(searchURL)
                    }

                } label: {
                    Image(systemName: "magnifyingglass.circle")
                }
            }
            if err {
                // Display any error messages in red
                Text(errmsg)
                    .foregroundColor(.red)
            }
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(titleString)
                .frame(width: 300)
                .lineLimit(5)
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
            let doc: Document = try SwiftSoup.parse(HTMLString)

            let elements = try doc.select("#package_list>li")
            print("Found \(elements.count) #package_list elements")
            for element in elements {
                /*
                 element example:
                 <li><a href="/fummicc1/SimpleRoulette"><h4>SimpleRoulette</h4><p>Create Roulette with ease.</p>
                   <ul class="keywords matching">
                    <li><span>Matching keywords: </span></li>
                    <li><span>bezier</span></li>
                   </ul>
                   <ul class="metadata">
                    <li class="identifier"><small>fummicc1/SimpleRoulette</small></li>
                    <li class="activity"><small>Active 17 days ago</small></li>
                    <li class="stars"><small>13 stars</small></li>
                   </ul></a></li>
                 */
                let keyword_set = try element.select("ul.keywords.matching li")
                if keyword_set.count > 1 {
                    for keyword_element in keyword_set.dropFirst() {
                        let keyword = try keyword_element.text()
                        print("Keyword found: \(keyword)")
                    }
                }
                let link = try element.select("a").first()!
                let href = try link.attr("href")
                print("HREF for link: \(href)")
                let packageName = try element.select("a h4").text()
                print("Package name: \(packageName)")
                let packageSummary = try element.select("a p").text()
                print("Package summary: \(packageSummary)")

                let identifier = try element.select("li.identifier").text()
                print("Identifier: \(identifier)")
            }

            // Parsing the found keywords for the search:
            let matching_keywords = try doc.select("section.keyword_results ul.keywords li")
            print("Found \(matching_keywords.count) matching keywords")
            for keyword_element in matching_keywords {
                let keyword = try keyword_element.text()
                print("found: \(keyword)")
            }

            // Parsing pagination if available
            let next_pagination = try doc.select("ul.pagination li.next")
            let previous_pagination = try doc.select("ul.pagination li.previous")
            print("Found \(next_pagination.count) next pagination links")
            print("Found \(previous_pagination.count) previous pagination links")

            titleString = try doc.title()
            print("Title: \(titleString)")
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
