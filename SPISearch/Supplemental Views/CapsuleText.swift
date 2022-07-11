//
//  CapsuleText.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SwiftUI

struct CapsuleText: View {
    var text: String
    #if os(iOS)
        @Environment(\.horizontalSizeClass) var horizontalSizeClass

        var body: some View {
            if horizontalSizeClass == .compact {
                Text(text)
                    .font(.caption.bold())
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .foregroundColor(.white)
                    .background(.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                Text(text)
                    .font(.callout.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .foregroundColor(.white)
                    .background(.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    #else
        var body: some View {
            Text(text)
                .font(.callout.bold())
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .foregroundColor(.white)
                .background(.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    #endif

    init(_ text: String) {
        self.text = text
    }
}

struct CapsuleText_Previews: PreviewProvider {
    static var previews: some View {
        CapsuleText("something")
    }
}
