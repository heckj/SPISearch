# SPISearch

A utility app (macOS & iOS) to explore and review search results from Swift Package Index.

Testflight Links:

- [SPISearch](https://testflight.apple.com/join/DaVCrzZp) (iOS and macOS apps)

## Search Ranking

This started with an exploration into [a search issue I found in 2022](https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/1859) with the [Swift Package Index](https://swiftpackageindex.com/).
The first version of this app allowed me to invoke search and parse the results from the web interface, and compare sets of results as I was trying out variations to improve the search.
A year down the road, and the parser no longer matched the output to the web page, there's a formal API, and I wanted to scale up the collections of search significantly.
Version 2.0 of this app isn't compatible at all with the earlier versions, but now supports collecting and reviewing much large collections of search results.

The core question that this tooling is meant to help answer is "Are these search results better".
Ranking search results is an inherently subjective measure, with a human needing to provide feedback to know "Is the search result relevant".
This app provide some convenience and expediency to look at the results in a collection and evaluate them for relevancy.

The SPISearch app _no longer_ directly collects search results, instead importing a crafted JSON file, leveraging the [SPISearchResult](https://github.com/heckj/SPISearchResult) project to define the encoding and parameters.
There is a command-line tool, included with this repository and Xcode project: `CaptureSearches` that calls the API endpoint of an instance of Swift Package Index and generates the relevant JSON file.
On the development/staging server for Swift Package Index, this requires an API key.
Provide the API key by setting an environment variable before you invoke `CaptureSearches`.
The tool takes in a text file with queries, and invokes them with a delay to capture and write the results.
As an example:

```bash
export SPI_API_TOKEN=eyJhb...iCcVPLY
CaptureSearches ~/your_file_of_queries
```

I used the [queries.txt](https://github.com/heckj/SPISearch/blob/main/SPISearchTests/queries.txt) to capture the JSON stored with the project as a test sample: [searchcollection_staging_9dec2023.txt](https://github.com/heckj/SPISearch/blob/main/SPISearchTests/searchcollection_staging_9dec2023.txt).

## Using the App

This utility app is a document-based app, which unfortunately makes understanding what it is, and does, quite obtuse - as it starts with a document browser and no explanation or detail.
When you open a new document, there's a button to import search queries, and the app shows you details and lets you review results from there.

## Document Format

The app uses a `Codable` data model, so the end results stored from the document as straight JSON that can be opened and read by any text editor, or processed conveniently using tools such as [jq](https://stedolan.github.io/jq/).

## Contributing

Pull requests and contributions are welcome. Please be considerate.
I'm tracking my development plans (and progress) for this app with [GitHub Issues](https://github.com/heckj/SPISearch/issues), and progress with on [an SPISearch project board](https://github.com/users/heckj/projects/1).
All submissions to the project are accepted under the MIT license.
If you don't agree with this licensing of your submission, please don't make a pull request.

The current code has some internal documentation, viewed within Xcode, by invoking `Product` `>` `Build Documentation`.
