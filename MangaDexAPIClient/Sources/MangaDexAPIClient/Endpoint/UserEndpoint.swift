//
//  UserEndpoint.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 28/12/24.
//

import Foundation
import Get

public extension MangaDexAPI {
    struct User: Sendable {}
}

// MARK: - Get logged in user

public struct GetLoggedInUserResponse: Decodable, Sendable {
    public let data: User
}

public extension MangaDexAPI.User {
    static func me() -> Request<GetLoggedInUserResponse> {
        Request(path: "/user/me")
    }
}

// MARK: - Get user followed manga feed

public struct GetUserFollowedMangaFeedResponse: Decodable, Sendable {
    public let limit: Int
    public let offset: Int
    public let data: [Chapter]
}

public extension MangaDexAPI.User {
    static func followedMangaFeed(
        pagination: Pagination,
        order: [MangaDexAPI.Chapter.ListSortOptions: SortOrder] = [:],
        includes: [MangaDexAPI.Chapter.Reference] = [.scanlationGroup]
    ) -> Request<GetUserFollowedMangaFeedResponse> {
        var query: [URLQueryItem] = []
        query.append(contentsOf: pagination.queryItems)
        query.append(contentsOf: order.queryItems)
        query.append(contentsOf: includes.queryItems)

        return Request(path: "/user/follows/manga/feed", query: query.map { ($0.name, $0.value) })
    }
}
