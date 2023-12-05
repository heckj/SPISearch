import ArgumentParser
import Foundation

@main
struct CaptureSearches: ParsableCommand {
    @Argument(help: "A file with the search queries to use.")
    var requestedFile: String

    @Option(help: "A file with the search queries to use.")
    var host: SPISearchHosts = .localhost

    mutating func run() throws {
        let info = ProcessInfo.processInfo
        // print("env [PWD] : \(String(describing: info.environment["PWD"]))")
        // print("arguments to app \(info.arguments)")
        if let pwd = info.environment["PWD"] {
            // print("current directory: \(URL(fileURLWithPath: pwd))")
            let fileURL = URL(fileURLWithPath: requestedFile, relativeTo: URL(fileURLWithPath: pwd))
            print("fileURL constructed: \(fileURL)")

//            do {
//            } catch {
//                print("Error: \(error)")
//                print(CommandLine.arguments.dropFirst().joined(separator: " "))
//                print(ReportSearchRank.helpMessage())
//            }
        }
    }
}
