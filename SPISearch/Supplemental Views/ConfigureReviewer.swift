//
//  ConfigureReviewer.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/11/22.
//

import SPISearchResult
import SwiftUI

struct ConfigureReviewer: View {
    @Environment(\.dismiss) var dismiss

    @Binding var document: SearchRankDocument

    let reviewerID: UUID = SPISearchApp.reviewerID()

    @AppStorage(SPISearchApp.reviewerNameKey) var localReviewerName: String = ""
    @State var reviewerName: String = ""

    var body: some View {
        Form {
            Section("Reviewer") {
                #if os(iOS)
                    HStack(alignment: .firstTextBaseline) {
                        TextField(text: $reviewerName) {
                            Text("Reviewer name")
                        }
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                        Button {
                            if localReviewerName != reviewerName {
                                localReviewerName = reviewerName
                            }
                            dismiss()
                        } label: {
                            Text("Submit")
                        }
                    }.padding()
                #else // macOS version - vertical display in sheet
                    VStack {
                        Text("Enter a reviewer ID to rank searches.")
                        TextField(text: $reviewerName) {
                            Text("ID")
                        }
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                        Button {
                            if localReviewerName != reviewerName {
                                localReviewerName = reviewerName
                                document.searchRanking.addOrUpdateEvaluator(reviewerId: reviewerID,
                                                                            reviewerName: localReviewerName)
                            }
                            dismiss()
                        } label: {
                            Text("Submit")
                        }
                    }.padding()
                #endif
            }.onAppear {
                reviewerName = localReviewerName
                if !localReviewerName.isEmpty {
                    document.searchRanking.addOrUpdateEvaluator(reviewerId: reviewerID,
                                                                reviewerName: localReviewerName)
                }
            }
        }
    }
}

private struct HostingView: View {
    @State private var showingSheet = false
    @Binding var document: SearchRankDocument
    var body: some View {
        VStack {
            Button("Show Sheet") {
                showingSheet.toggle()
            }
            .sheet(isPresented: $showingSheet) {
                ConfigureReviewer(document: $document)
            }
        }
    }
}

struct ConfigureReviewer_Previews: PreviewProvider {
    static var previews: some View {
        HostingView(document: .constant(SearchRankDocument(SearchResult.exampleCollection)))
    }
}
