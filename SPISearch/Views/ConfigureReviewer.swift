//
//  ConfigureReviewer.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/11/22.
//

import SwiftUI

struct ConfigureReviewer: View {
    // @Environment(\.presentationMode) var presentation
    @Environment(\.dismiss) var dismiss
    @AppStorage(SPISearchApp.reviewerKey) var localReviewer: String = ""
    // To allow creating a local reviewer document if the
    // document doesn't already have one.
    @Binding var document: SearchRankDocument
    @State var reviewerId: String = ""

    var body: some View {
        Form {
            #if os(iOS)
                HStack(alignment: .firstTextBaseline) {
                    Text("Enter your reviewer ID")
                    TextField(text: $reviewerId) {
                        Text("reviewer id")
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    Button {
                        if localReviewer != reviewerId {
                            localReviewer = reviewerId
                            document.searchRanking.addRelevanceSet(for: localReviewer)
                        }
                        dismiss()
                    } label: {
                        Text("Submit")
                    }
                }.padding()
            #else // macOS version - vertical display in sheet
                VStack {
                    Text("Enter a reviewer ID to rank searches.")
                    TextField(text: $reviewerId) {
                        Text("ID")
                    }
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    Button {
                        if localReviewer != reviewerId {
                            localReviewer = reviewerId
                            document.searchRanking.addRelevanceSet(for: localReviewer)
                        }
                        dismiss()
                    } label: {
                        Text("Submit")
                    }
                }.padding()
            #endif
        }.onAppear {
            reviewerId = localReviewer
        }
    }

    init(_ document: Binding<SearchRankDocument>) {
        _document = document
    }
}

struct HostingView: View {
    @State private var showingSheet = false
    var body: some View {
        Button("Show Sheet") {
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
            ConfigureReviewer(.constant(SearchRank.extendedExample))
        }
    }
}

struct ConfigureReviewer_Previews: PreviewProvider {
    static var previews: some View {
        // ConfigureReviewer(.constant(SearchRank.extendedExample))
        HostingView()
    }
}
