import SwiftUI

struct SettingsFormView: View {
    @AppStorage(SPISearchApp.reviewerNameKey) private var localReviewerName: String = ""
    @State var reviewerName: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section("Reviewer") {
                VStack {
                    Text("Reviewer ID: \(SPISearchApp.reviewerID())")
                    Text("Enter a name to display as evaluator.")
                    TextField(text: $reviewerName) {
                        Text("ID")
                    }
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
                }
                .padding()
            }
        }
        .padding()
        .onAppear {
            reviewerName = localReviewerName
        }
    }
}

struct SettingsFormView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFormView()
    }
}
