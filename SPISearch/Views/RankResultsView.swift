//
//  RankResultsView.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/4/22.
//

import SwiftUI

struct RankResultsView: View {
    @AppStorage(SPISearchApp.reviewerKey) var localReviewer: String = ""
    // For editing an individual relevance record
    @Binding var relevanceRecord: RelevanceRecord
    // To allow creating a local reviewer document if the
    // document doesn't already have one.
    @Binding var document: SearchRankDocument

    // The search result to display for the purposes of
    // ranking the matched keywords and search results.
    let recordedSearch: RecordedSearchResult
    /// Returns `true` if the reviewer identified in the App's user defaults
    /// matches the reviewer stored for the current relevance record we're
    /// editing (or viewing)
    var viewOnly: Bool {
        relevanceRecord.reviewer != localReviewer
    }

    func highlightColor(_ relevance: Relevance) -> Color {
        switch relevance {
        case .unknown:
            return .yellow.opacity(0.5)
        case .not:
            return .gray.opacity(0.1)
        case .partial:
            return .green.opacity(0.2)
        case .relevant:
            return .green.opacity(0.5)
        }
    }

    var body: some View {
        // If we don't have a local reviewer set in the
        // App's user defaults, pre-empt this view to get
        // one set up.
        if localReviewer.isEmpty {
            ConfigureReviewer($document)
        } else {
            // Display the search results in order to rank
            // (or just display, if viewOnly = `true`)
            // their relevance.
            ScrollViewReader { proxy in
                List {
                    Section {
                        Text("Relevancy for search terms: **\(recordedSearch.searchTerms)**, ranking reviewer: \(localReviewer)")
                    }
                    Section {
                        ForEach(recordedSearch.resultSet.results) { result in
                            HStack {
                                PackageSearchResultView(result)
                                Spacer()
                                if viewOnly {
                                    RelevanceResultView(relevanceRecord.packages[result.id])
                                        .background(highlightColor(relevanceRecord.packages[result.id]))
                                } else {
                                    RelevanceSelectorView($relevanceRecord.packages[result.id])
                                        .background(highlightColor(relevanceRecord.packages[result.id]))
                                }
                            }
                            #if os(macOS)
                                Divider()
                                // replace with `.listRowSeparator(.visible)` for macOS 13+
                            #endif
                        }
                    } header: {
                        HStack {
                            Text("Ranking has \(relevanceRecord.packages.count) of \(recordedSearch.resultSet.results.count) search entries.")
                            if !recordedSearch.resultSet.results.isEmpty {
                                if #available(iOS 16, macOS 12.4, *) {
                                    // progressview on iOS 15 and lower is an indeterminate progress indicator
                                    // and looks like crap, so constraining this to iOS 16+, and macOS 12+
                                    ProgressView(value: Double(relevanceRecord.packages.count) / Double(recordedSearch.resultSet.results.count))
                                        .progressViewStyle(.circular)
                                }
                            }
                        }
                    }
                    Section {
                        ForEach(recordedSearch.resultSet.matched_keywords, id: \.self) { keyword in
                            HStack {
                                CapsuleText(keyword)
                                Spacer()
                                if viewOnly {
                                    RelevanceResultView(relevanceRecord.keywords[keyword])
                                        .background(highlightColor(relevanceRecord.keywords[keyword]))
                                } else {
                                    RelevanceSelectorView($relevanceRecord.keywords[keyword])
                                        .background(highlightColor(relevanceRecord.keywords[keyword]))
                                }
                            }
                            .tag(keyword)
                            #if os(macOS)
                                Divider()
                                // replace with `.listRowSeparator(.visible)` for macOS 13+
                            #endif
                        }
                    } header: {
                        HStack {
                            Text("Ranking has \(relevanceRecord.keywords.count) of \(recordedSearch.resultSet.matched_keywords.count) keyword entries.")
                            if !recordedSearch.resultSet.matched_keywords.isEmpty {
                                if #available(iOS 16, macOS 12.4, *) {
                                    // progressview on iOS 15 and lower is an indeterminate progress indicator
                                    // and looks like crap, so constraining this to iOS 16+, and macOS 12+
                                    ProgressView(value: Double(relevanceRecord.keywords.count) / Double(recordedSearch.resultSet.matched_keywords.count))
                                        .progressViewStyle(.circular)
                                }
                            }
                        }
                    }
                } // List
                .onChange(of: relevanceRecord) { _ in
                    if let firstUnrankedSearch = recordedSearch.resultSet.results.first(where: { searchResult in
                        if relevanceRecord.packages[searchResult.id] == .unknown {
                            return true
                        }
                        return false
                    }) {
                        proxy.scrollTo(firstUnrankedSearch.id, anchor: .center)
                    } else if let firstUnrankedKeyword = recordedSearch.keywords.first(where: { keyword in
                        if relevanceRecord.keywords[keyword] == .unknown {
                            return true
                        }
                        return false
                    }) {
                        proxy.scrollTo(firstUnrankedKeyword, anchor: .center)
                    }
                }
            } // ScrollViewReader
        } // if-else localReviewer.isEmpty
    }

    init(searchRankDoc: Binding<SearchRankDocument>, relevanceRecordBinding: Binding<RelevanceRecord>, recordedSearch: RecordedSearchResult) {
        _document = searchRankDoc
        _relevanceRecord = relevanceRecordBinding
        self.recordedSearch = recordedSearch
    }
}

struct RankingSearchResultsView_Previews: PreviewProvider {
    struct TempView: View {
        @State var relevanceRecord: RelevanceRecord = .init("testing")
        var body: some View {
            RankResultsView(searchRankDoc: .constant(SearchRank.extendedExample), relevanceRecordBinding: $relevanceRecord, recordedSearch: RecordedSearchResult.example)
        }
    }

    static var previews: some View {
        TempView()
    }
}
