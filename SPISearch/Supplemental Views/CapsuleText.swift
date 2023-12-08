//
//  CapsuleText.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct CapsuleText: View {
    var text: String

    var body: some View {
        Text(text)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundColor(.white)
            .background(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    init(_ text: String) {
        self.text = text
    }
}

struct CapsuleText_Previews: PreviewProvider {
    static var previews: some View {
        CapsuleText("something")
    }
}
