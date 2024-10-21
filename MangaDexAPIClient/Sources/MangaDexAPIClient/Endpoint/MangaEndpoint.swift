//
//  MangaEndpoint.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation
import Get

public extension MangaDexAPI {
    /// Manga resource
    struct Manga: Sendable {
        static let basePath = "manga"
        let path: String

        public init(id: UUID) {
            path = "\(Self.basePath)/\(id.uuidString.lowercased())"
        }
    }
}

// MARK: - Get Manga List

public struct GetMangaListResponse: Decodable {
    public let limit: Int
    public let offset: Int
    public let data: [Manga]
}

public extension MangaDexAPI.Manga {
    enum Reference: String, Sendable {
        case manga
        case cover = "cover_art"
        case author
        case artist
        case tag
        case creator
    }

    enum ListSortOptions: String, Sendable {
        case latestUploadChapter
        case followedCount
        case createdAt
    }

    /// Get manga list
    static func list(
        pagination: Pagination,
        order: [ListSortOptions: SortOrder] = [:],
        includes: [Reference] = [.artist, .author, .cover],
        createdAtSince: Date? = nil,
        ids: [UUID]? = nil
    ) -> Request<GetMangaListResponse> {
        var query: [URLQueryItem] = []

        query.append(contentsOf: pagination.queryItems)
        query.append(contentsOf: order.queryItems)
        query.append(contentsOf: includes.queryItems)

        if let createdAtSince {
            query.append(URLQueryItem(
                name: "createdAtSince",
                value: createdAtSince.formatted(.mangaDexAPIDate)
            ))
        }

        if let ids {
            let ids = ids.map { $0.uuidString.lowercased() }
            query.append(contentsOf: ids.map { URLQueryItem(name: "ids[]", value: $0) })
        }

        return Request(
            path: Self.basePath,
            query: query.map { ($0.name, $0.value) }
        )
    }
}

// MARK: - Helpers

private extension [MangaDexAPI.Manga.ListSortOptions: SortOrder] {
    var queryItems: [URLQueryItem] {
        map { URLQueryItem(name: "order[\($0.rawValue)]", value: $1.rawValue) }
    }
}

private extension [MangaDexAPI.Manga.Reference] {
    var queryItems: [URLQueryItem] {
        map { URLQueryItem(name: "includes[]", value: $0.rawValue) }
    }
}
