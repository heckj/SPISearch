import Foundation

/// A struct that captures "lines" of data exported from Loki in JSON output format
public struct LokiLogExport: Codable, Sendable, Comparable {
    public static func < (lhs: LokiLogExport, rhs: LokiLogExport) -> Bool {
        lhs.timestamp < rhs.timestamp
    }

    public let line: String
    public let timestamp: String
}

// MARK: The top two lines that have encoded search query data

// The search query itself - which includes a search ID to use for connecting with fragments
struct SearchResultQuery: Hashable, Codable {
    let searchID: UUID
    let query: String
}

// A search result fragment
struct SearchResultFragment: Hashable, Codable, Sendable {
    let searchID: UUID
    let result: FragmentSearchResult?

    enum CodingKeys: String, CodingKey {
        case searchID = "id"
        case result = "r"
    }
}

// The structure below maps to the SwiftPackageIndex internal fields and structs that
// are encoded into JSON in the log lines.
enum FragmentSearchResult: Codable, Hashable, Equatable {
    case author(AuthorResult)
    case keyword(KeywordResult)
    case package(PackageResult)
}

struct AuthorResult: Codable, Hashable, Equatable {
    var name: String
}

struct KeywordResult: Codable, Hashable, Equatable {
    var keyword: String
}

struct PackageResult: Codable, Hashable, Equatable {
    var packageId: UUID
    var packageName: String?
    var packageURL: String
    var repositoryName: String
    var repositoryOwner: String
    var stars: Int?
    var lastActivityAt: Date?
    var summary: String?
    var keywords: [String]?
    var hasDocs: Bool
}
