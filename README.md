# SPISearch

An app (macOS & iOS) to explore the search results from Swift Package Index.

## Search Ranking

I ran into [an issue with the search mechanisms](https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/1859) in Swift Package Index.
This app is a means of invoking searches against the production instance of Swift Package Index, and in the future a local instance, in order to compare and rate the search results for different implementations.

The core question that this tooling is meant to help answer is "Are these search results better".
Ranking search results is an inherently subjective measure, with a human needing to provide feedback to know "Is the search result relevant".

In [the bug I opened](https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/1859), Dave provided me with a number of potential searches to use as a baseline, and I wanted to be able to query them easily and get a comparison, as well as have a quick little tool that would make it easier to capture what someone thought of as relevant. 
That's what this app is about.

The provided test queries:

- https://swiftpackageindex.com/search?query=bezier
- https://swiftpackageindex.com/search?query=gauss-krueger
- https://swiftpackageindex.com/search?query=wtv
- https://swiftpackageindex.com/search?query=iso639-1
- https://swiftpackageindex.com/search?query=具方法 (=> chinese for 'method')
- https://swiftpackageindex.com/search?query=作为弹幕 (=> chinese for 'as a barrage')

