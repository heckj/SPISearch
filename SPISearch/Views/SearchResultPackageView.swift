//
//  SearchResultPackageView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/3/22.
//

import SPISearchResult
import SwiftUI

struct SearchResultPackageView: View {
    let package: SearchResult.Package
    let search_result_keywords: [String]

    #if os(iOS)
        @Environment(\.horizontalSizeClass) var horizontalSizeClass

        var body: some View {
            VStack(alignment: .leading) {
                if horizontalSizeClass == .compact {
                    VStack {
                        VStack(alignment: .leading) {
                            Text(package.id.description)
                                .font(.title)
                                .textSelection(.enabled)
                            Text("\(package.stars) github stars")
                                .font(.callout)
                                .textSelection(.enabled)
                        }
                        HStack(alignment: .firstTextBaseline) {
                            ForEach(package.package_keywords, id: \.self) { word in
                                if search_result_keywords.contains(word) {
                                    CapsuleText(word)
                                        .textSelection(.enabled)
                                }
                            }
                        }
                        Text(package.summary ?? "")
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                    }
                } else {
                    VStack(alignment: .leading) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(package.id.description)
                                .font(.title)
                                .textSelection(.enabled)
                            Text("\(package.stars) github stars")
                                .font(.callout)
                                .textSelection(.enabled)
                        }
                        HStack(alignment: .firstTextBaseline) {
                            ForEach(package.package_keywords, id: \.self) { word in
                                if search_result_keywords.contains(word) {
                                    CapsuleText(word)
                                        .textSelection(.enabled)
                                }
                            }
                        }
                        Text(package.summary ?? "")
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                    }                }
            }
        }
    #else // macOS
        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text(package.id.description)
                        .font(.title)
                        .textSelection(.enabled)
                    Text("\(package.stars) github stars")
                        .font(.callout)
                        .textSelection(.enabled)
                }
                HStack(alignment: .firstTextBaseline) {
                    ForEach(package.package_keywords, id: \.self) { word in
                        if search_result_keywords.contains(word) {
                            CapsuleText(word)
                                .textSelection(.enabled)
                        }
                    }
                }
                Text(package.summary ?? "")
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
        }
    #endif

    init(_ p: SearchResult.Package, keywords: [String]) {
        package = p
        search_result_keywords = keywords
    }
}

struct SearchResultPackageView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultPackageView(
            SearchResult.exampleCollection[1].packages[1],
            keywords: SearchResult.exampleCollection[1].keywords
        )
    }
}
