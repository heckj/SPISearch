import ArgumentParser
import Foundation

// Example invocation
// /Users/heckj/Library/Developer/Xcode/DerivedData/SPISearch-auuhugbmpqngrkepntoqrhshlkmh/Build/Products/Debug/CaptureSearches searchRankDocs/queries.txt

@main
struct CaptureSearches: AsyncParsableCommand {
    @Argument(help: "A file with the search queries to use.")
    var requestedFile: String

    @Option(help: "The SPI environment to search. One of \(SPISearchHosts.allCases.map(\.rawValue)).")
    var host: SPISearchHosts = .staging

    @Option(help: "File name to write with the captured searches.")
    var encodedsearchcollection: String = "searchcollection.txt"
    
    mutating func run() async throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601

        let info = ProcessInfo.processInfo
        guard let apiToken = info.environment["SPI_API_TOKEN"] else {
            fatalError("No SPI_API_TOKEN found as an environment variable")
        }
        let path = (requestedFile as NSString).expandingTildeInPath
        let fileURLtoRead = URL(filePath: path).standardized
        print("Reading queries from \(fileURLtoRead.absoluteString)")
        let fileURLtoWrite = URL(fileURLWithPath: encodedsearchcollection)

            let outputFilePath = fileURLtoWrite.path()
            print("Writing to file: \(outputFilePath)")
            // Check for file presence and create it if it does not exist
            let fileManager = FileManager.default

            // If file exists, remove it
            if fileManager.fileExists(atPath: outputFilePath) {
                try fileManager.removeItem(atPath: outputFilePath)
            }

            // Create file and open it for writing
            fileManager.createFile(atPath: outputFilePath, contents: Data(" ".utf8), attributes: nil)
            if let fileHandle = FileHandle(forWritingAtPath: outputFilePath),
               let newlineAsData = "\n".data(using: .utf8)
            {
                // Write data
                fileHandle.write("Test line 1\n".data(using: .utf8)!)

                do {
                    let (bytes, response) = try await URLSession.shared.bytes(from: fileURLtoRead)
                    print(" - processing \(response.expectedContentLength) bytes:")
                    for try await line in bytes.lines {
                        // do something...
                        print("Requesting search results for '\(line)'")
                        let searchresult = try await makeASearchResult(terms: line,
                                                                       from: host,
                                                                       apiToken: apiToken)
                        dump(searchresult)
                        let encoded = try jsonEncoder.encode(searchresult)
                        fileHandle.write(encoded)
                        fileHandle.write(newlineAsData)
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }

                // Close file
                fileHandle.closeFile()
            } else {
                fatalError("nil file handle for output file")
            }
        }
    
}
