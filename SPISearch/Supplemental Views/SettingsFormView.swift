//
//  SettingsFormView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/7/22.
//

import SwiftUI

struct SettingsFormView: View {
    @AppStorage(SPISearchApp.reviewerIDKey) var localReviewerId: String = UUID().uuidString
    @AppStorage(SPISearchApp.reviewerNameKey) private var reviewerName: String = ""
    var body: some View {
        Form {
            Section("Evaluator \(localReviewerId)") {
                HStack(alignment: .firstTextBaseline) {
                    TextField(text: $reviewerName) {
                        Text("Reviewer Name")
                    }
                    .disableAutocorrection(true)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
            }
        }
    }
}

struct SettingsFormView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFormView()
    }
}
