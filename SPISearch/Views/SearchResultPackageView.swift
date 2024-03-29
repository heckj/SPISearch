import SPISearchResult
import SwiftUI

struct SearchResultPackageView: View {
    let package: SearchResult.Package
    let search_result_keywords: [String]
    #if os(iOS)
        @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif

    var body: some View {
        VStack(alignment: .leading) {
            Text(package.name ?? "")
                .font(.title)
            Text(package.summary ?? "")
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .firstTextBaseline) {
                Text("Matching keywords:")
                #if os(iOS)
                    .font(horizontalSizeClass == .compact ? .caption : .body)
                #endif
                    .font(.body)
                FlowLayout(spacing: 4) {
                    ForEach(package.package_keywords, id: \.self) { word in
                        CapsuleText(word)
                            .textSelection(.enabled)
                    }
                }
                #if os(iOS)
                .font(horizontalSizeClass == .compact ? .caption.bold() : .body.bold())
                #endif
                .font(.body.bold())
            }

            HStack(alignment: .firstTextBaseline) {
                Text("\(package.id.description)")
                if let last_activity = package.last_activity {
                    Image(systemName: "bubble.right.fill")
                    Text("Active \(last_activity, style: .relative) ago")
                }
                Image(systemName: "star.fill")
                Text("\(package.stars) stars")
            }
            .font(.caption)
        }
        .textSelection(.enabled)
    }

    init(_ p: SearchResult.Package, keywords: [String]) {
        package = p
        search_result_keywords = keywords
    }
}

struct SearchResultPackageView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultPackageView(
            SearchResult.exampleCollection[1].packages[0],
            keywords: SearchResult.exampleCollection[1].keywords
        )
        SearchResultPackageView(
            SearchResult.exampleCollection[1].packages[1],
            keywords: SearchResult.exampleCollection[1].keywords
        )
        SearchResultPackageView(
            SearchResult.exampleCollection[1].packages[2],
            keywords: SearchResult.exampleCollection[1].keywords
        )
    }
}
