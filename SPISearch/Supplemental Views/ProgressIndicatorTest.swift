//
//  ProgressIndicatorTest.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/10/22.
//

import SwiftUI

struct ProgressIndicatorTest: View {
    var progress: Double = 0.4
    var body: some View {
        ProgressView(value: progress)
            .progressViewStyle(.circular)
    }
}

struct ProgressIndicatorTest_Previews: PreviewProvider {
    static var previews: some View {
        ProgressIndicatorTest()
    }
}
