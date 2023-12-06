//
//  ReportSearchRank.swift
//  ReportSearch
//
//  Created by Joseph Heck on 7/11/22.
//

import ArgumentParser
import Foundation

@main
struct ReportSearchRank: ParsableCommand {
    @Argument(help: "The searchrank document.")
    var requestedFiles: [String]

    mutating func run() throws {
        let myDoubleFormat: FloatingPointFormatStyle<Double> = .number.precision(.integerAndFractionLength(integer: 1, fraction: 3))
        let info = ProcessInfo.processInfo
        // print("env [PWD] : \(String(describing: info.environment["PWD"]))")
        // print("arguments to app \(info.arguments)")
        if let pwd = info.environment["PWD"] {
            do {
                for report in requestedFiles {
                    // print("current directory: \(URL(fileURLWithPath: pwd))")
                    let fileURL = URL(fileURLWithPath: report, relativeTo: URL(fileURLWithPath: pwd))
                    // print("fileURL constructed: \(fileURL)")
                    let searchRanking = try JSONDecoder().decode(SearchRank.self, from: Data(contentsOf: fileURL))

//                    if let medianRanking = searchRanking.medianRelevancyRanking {
//                        for storedSearch in searchRanking.storedSearches {
//                            let searchStringRep = "\(storedSearch.recordedDate.formatted(date: .abbreviated, time: .omitted)) (\(storedSearch.host))"
//                            print("'\(fileURL.lastPathComponent)' query terms: \(searchRanking.storedSearches.first?.searchTerms ?? "")")
//
//                            if let metrics = SearchMetrics(searchResult: storedSearch,
//                                                           ranking: medianRanking)
//                            {
//                                print(" - \(searchStringRep)")
//                                print("   -            Precision: \(metrics.precision.formatted(myDoubleFormat))")
//                                print("   -               Recall: \(metrics.recall.formatted(myDoubleFormat))")
//                                print("   - Mean Reciprocal Rank: \(metrics.meanReciprocalRank.formatted(myDoubleFormat))")
//                                print("   - NDCG: \(metrics.ndcg.formatted(myDoubleFormat))")
//                            } else {
//                                print(" - \(searchStringRep)\n  ranking is incomplete, metrics are unavailable.")
//                            }
//                        }
//                    } else {
//                        print("No rankings are available in \(report)")
//                    }
                }
            } catch {
                print("Error: \(error)")
                print(CommandLine.arguments.dropFirst().joined(separator: " "))
                print(ReportSearchRank.helpMessage())
            }
        }
    }
}
