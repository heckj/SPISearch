import Foundation

public struct LokiLogExport: Codable, Sendable, Comparable {
    public static func < (lhs: LokiLogExport, rhs: LokiLogExport) -> Bool {
        lhs.timestamp < rhs.timestamp
    }

    public let line: String
    public let timestamp: String
}

struct SearchResultQuery: Hashable, Codable {
    let searchID: UUID
    let query: String
}

struct SearchResultFragment: Hashable, Codable, Sendable {
    let searchID: UUID
    let result: FragmentSearchResult?

    enum CodingKeys: String, CodingKey {
        case searchID = "id"
        case result = "r"
    }
}

enum FragmentSearchResult: Codable, Hashable, Equatable {
    case author(AuthorResult)
    case keyword(KeywordResult)
    case package(PackageResult)

    var isPackage: Bool {
        switch self {
        case .author, .keyword:
            return false
        case .package:
            return true
        }
    }

    var authorResult: AuthorResult? {
        switch self {
        case let .author(result):
            return result
        case .keyword, .package:
            return nil
        }
    }

    var keywordResult: KeywordResult? {
        switch self {
        case let .keyword(result):
            return result
        case .author, .package:
            return nil
        }
    }

    var packageResult: PackageResult? {
        switch self {
        case let .package(result):
            return result
        case .author, .keyword:
            return nil
        }
    }
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

    init?(packageId: UUID?,
          packageName: String?,
          packageURL: String?,
          repositoryName: String?,
          repositoryOwner: String?,
          stars: Int?,
          lastActivityAt: Date?,
          summary: String?,
          keywords: [String]?,
          hasDocs: Bool)
    {
        guard let packageId,
              let packageURL,
              let repositoryName,
              let repositoryOwner
        else { return nil }

        self.packageId = packageId
        self.packageName = packageName
        self.packageURL = packageURL
        self.repositoryName = repositoryName
        self.repositoryOwner = repositoryOwner
        self.stars = stars
        self.lastActivityAt = lastActivityAt
        self.summary = summary
        self.keywords = keywords
        self.hasDocs = hasDocs
    }
}
