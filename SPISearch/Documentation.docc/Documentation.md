# ``SPISearch``

A tool for capturing, evaluating, and comparing search results for Swift Package Index. 

## Overview

A utility application to capture, review, compare, and rank search results from Swift Package Index.

## Topics

### About the SPISearch App

- <doc:AppUseCases>
- <doc:MeasuringSearchRelevance>

### App and Document Model

- <doc:AppDataStructures>
- ``SPISearch/SPISearchApp``
- ``SPISearch/SearchRankDocument``

### Data Model

- ``SPISearch/SearchRank``
- ``SPISearch/SearchResultSet``
- ``SPISearch/RelevanceRecord``
- ``SPISearch/KeywordRelevance``
- ``SPISearch/PackageIdentifierRelevance``
- ``SPISearch/Relevance``
- ``SPISearch/RecordedSearchResult``
- ``SPISearch/PackageSearchResult``
- ``SPISearch/ComputedRelevancyValues``
- ``SPISearch/SearchMetrics``

### Collector and Parser

- ``SPISearch/SPISearchParser``

### App Views

- ``SPISearch/SearchRankEditorView``
- ``SPISearch/SearchRankDocumentOverview``
- ``SPISearch/RankResultsView``
- ``SPISearch/ConfigureReviewer``
- ``SPISearch/SearchingView``
- ``SPISearch/RecordedSearchResultView``
- ``SPISearch/PackageSearchResultView``

### Supplementary Views

- ``SPISearch/SettingsFormView``
- ``SPISearch/SearchResultSetSummaryView``
- ``SPISearch/RelevanceSetSummaryView``
- ``SPISearch/RelevanceSelectorView``
- ``SPISearch/RelevanceResultView``
- ``SPISearch/CapsuleText``
- ``SPISearch/SearchMetricsView``
