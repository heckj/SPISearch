# SPISearch core data structures 

Something, something, data flow

## Overview

The lowest level of the raw data to be evaluated is a search result, made up of query terms, a date when it was requested, and the results retrieved. 
The results need to minimally include a unique package identifier, and may include other information helpful to ranking. 
This additional detail includes the summary of each package as provided by the index as well as related keywords.

```
SearchResult: Hashable, Comparable, Identifiable
- date/time stamp
- query_terms
- keywords : [String]
- packages : [PackageSearchResult]

``SwiftPackageIndexAPI/Package``: Codable
  --> pull out the bits we're interested in for storing
- PackageId (owner/repository)
- title
- summary
```

``PackageId``

The searches are grouped into a collection, which generally is imported or created, and provides the basis on which ranking happens.
As a general pattern, it is expected that the collections do not change after ranking has started, although that should be accommodated in the app.
Once set in place, the collection is generally treated as a read-only set of data.

```
CollectionOfSearchResults:
- searchResults: Set(SearchResult)
```

The ranking then happens by individual providing the ranking, and is stored in the document as a parallel data structure.
Determining if the rankings are complete is based entirely on the _whole_ set of searches in the collection.
Rankings are stored per evaluator, then by set of search terms as a contiguous string.
The rankings list all the packages that were provided during the period of the search collection, and track a rank evaluation.
The relevant ranking is on an intentionally small gradient, encapsulated by ``Relevance``.
By default relevance is marked as ``Relevance/unknown``, and set by the user to one of the following values:

- ``Relevance/not``
- ``Relevance/partial``
- ``Relevance/relevant``

```
CollectionOfEvaluations:
- [Evaluations]

RelevanceEvaluation: Hashable, Comparable, Identifiable
- evaluator
- rankings: [ReviewSet]

ReviewSet:
- query_terms
- reviews: [package identifier:relevance]
```
