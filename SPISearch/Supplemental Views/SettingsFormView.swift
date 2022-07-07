//
//  SettingsFormView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/7/22.
//

import SwiftUI

struct SettingsFormView: View {
    @AppStorage(SPISearchApp.reviewerKey) private var reviewerId: String = ""
    var body: some View {
        Form {
            HStack(alignment: .firstTextBaseline) {
                Text("Enter your reviewer ID")
                TextField(text: $reviewerId) {
                    Text("reviewer id")
                }
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
            }
            .padding()
        }
    }
}

struct SettingsFormView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFormView()
    }
}
