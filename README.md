# SPISearch

An app (macOS & iOS) to explore the search results from Swift Package Index.

Testflight Links:

- [macOS SPIIndex](https://testflight.apple.com/join/DaVCrzZp)
- iOS SPIIndex: _pending testflight review_

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

## Using the App

This utility app is a document-based app, which unfortunately makes understanding what it is, and does, quite obtuse - as it starts with a document browser and no explanation or detail.
To start, make a new document - and with any empty new document, the app presents a text field for query terms. 
Update the terms to your liking, hit return (or the search button), and a new document will be created with the search results.

Once the search results are stored, you can see any sets of stored search results, store another set of search results for the same query, and add relevance review details to the results.

The primary goal of this utility app is to have a single set of query terms, and to capture one or more sets of search results, add relevancy rankings to them - to be be able to compare those to saved or future searches.

## Document Format

The app uses a `Codable` data model, so the end results stored from the document as straight JSON that can be opened and read by any text editor, or processed conveniently using tools such as [jq](https://stedolan.github.io/jq/).

## Contributing

Pull requests are welcome. 
I'm tracking my development plans (and progress) for this app with [GitHub Issues](https://github.com/heckj/SPISearch/issues), and progress with on [an SPISearch project board](https://github.com/users/heckj/projects/1).
All submissions to the project are to be accepted under the MIT license.
