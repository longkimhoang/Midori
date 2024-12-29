//
//  UserEndpoint.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 28/12/24.
//

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
