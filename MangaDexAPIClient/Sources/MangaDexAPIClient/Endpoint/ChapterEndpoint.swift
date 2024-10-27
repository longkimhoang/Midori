//
//  ChapterEndpoint.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 27/10/24.
//

import Foundation
import Get

public extension MangaDexAPI {
    /// Chapter resource
    struct Chapter: Sendable {
        static let basePath = "chapter"
        let path: String

        public init(id: UUID) {
            path = "\(Self.basePath)/\(id.uuidString.lowercased())"
        }
    }
}

// MARK: - Get Chapter List

public struct GetChapterListResponse: Decodable, Sendable {
    public let limit: Int
    public let offset: Int
    public let data: [Chapter]
}

public extension MangaDexAPI.Chapter {
    enum Reference: String, Sendable {
        case manga
        case scanlationGroup = "scanlation_group"
        case user
    }

    enum ListSortOptions: String, Sendable {
        case createdAt
        case updatedAt
        case publishAt
        case readableAt
    }

    /// Get manga list
    static func list(
        pagination: Pagination,
        order: [ListSortOptions: SortOrder] = [:],
        includes: [Reference] = [.scanlationGroup]
    ) -> Request<GetMangaListResponse> {
        var query: [URLQueryItem] = []

        query.append(contentsOf: pagination.queryItems)
        query.append(contentsOf: order.queryItems)
        query.append(contentsOf: includes.queryItems)

        return Request(
            path: Self.basePath,
            query: query.map { ($0.name, $0.value) }
        )
    }
}

// MARK: - Helpers

private extension [MangaDexAPI.Chapter.ListSortOptions: SortOrder] {
    var queryItems: [URLQueryItem] {
        map { URLQueryItem(name: "order[\($0.rawValue)]", value: $1.rawValue) }
    }
}

private extension [MangaDexAPI.Chapter.Reference] {
    var queryItems: [URLQueryItem] {
        map { URLQueryItem(name: "includes[]", value: $0.rawValue) }
    }
}
