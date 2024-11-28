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
            path = "\(Manga.basePath)/\(id.uuidString.lowercased())"
        }
    }
}

// MARK: - Manga Reference

public extension MangaDexAPI.Manga {
    enum Reference: String, EndpointReference, Sendable {
        case manga
        case cover = "cover_art"
        case author
        case artist
        case tag
        case creator
    }
}

// MARK: - Get Manga List

public struct GetMangaListResponse: Decodable, Sendable {
    public let limit: Int
    public let offset: Int
    public let data: [Manga]
}

public extension MangaDexAPI.Manga {
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
            path: basePath,
            query: query.map { ($0.name, $0.value) }
        )
    }
}

// MARK: - Get Manga

public struct GetMangaResponse: Decodable, Sendable {
    public let data: Manga
}

public extension MangaDexAPI.Manga {
    /// Get manga
    func get(includes: [Reference] = [.artist, .author, .cover]) -> Request<GetMangaResponse> {
        var query: [URLQueryItem] = []
        query.append(contentsOf: includes.queryItems)

        return Request(path: path, query: query.map { ($0.name, $0.value) })
    }
}

// MARK: - Get Manga feed

public struct GetMangaFeedResponse: Decodable, Sendable {
    public let limit: Int
    public let offset: Int
    public let data: [Chapter]
}

public extension MangaDexAPI.Manga {
    /// Get manga feed
    func feed(
        pagination: Pagination,
        includes: [MangaDexAPI.Chapter.Reference] = [.scanlationGroup]
    ) -> Request<GetMangaFeedResponse> {
        var query: [URLQueryItem] = []
        query.append(contentsOf: pagination.queryItems)
        query.append(contentsOf: includes.queryItems)

        return Request(path: "\(path)/feed", query: query.map { ($0.name, $0.value) })
    }
}

// MARK: - Get Manga volumes & chapters

public extension MangaDexAPI.Manga {
    func aggregate(groups: [UUID] = []) -> Request<MangaAggregate> {
        var query: [URLQueryItem] = []
        query.append(contentsOf: groups.queryItems(name: "groups[]"))

        return Request(path: "\(path)/aggregate", query: query.map { ($0.name, $0.value) })
    }
}
