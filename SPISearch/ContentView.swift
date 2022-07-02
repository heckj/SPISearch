//
//  ContentView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/2/22.
//

import SwiftUI
import SwiftSoup

struct ContentView: View {
    
    @State var searchURL = "https://swiftpackageindex.com/"
    @State var err: Bool = false
    @State var errmsg: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("search", text: $searchURL)
                Button {
                    Task {
                        self.err = false
                        await loadData(searchURL)
                    }
                } label: {
                    Image(systemName: "tray.and.arrow.down")
                }
            }
            if (err) {
                Text(errmsg).foregroundColor(.red)
            }
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
    }
    
    func loadData(_ url: String) async {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            self.errmsg = "Invalid URL"
            self.err = true
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // more code to come
            do {
//               let html = "<html><head><title>First parse</title></head>"
//                   + "<body><p>Parsed HTML into a doc.</p></body></html>"
                let HTMLString = String(data: data, encoding: .utf8)!
                let doc: Document = try SwiftSoup.parse(HTMLString)
                try print(doc.text())
//               return try doc.text()
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
        } catch {
            print("Invalid data")
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
