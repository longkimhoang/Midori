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

public extension MangaDexAPI.User {
    static func me() -> Request<User> {
        Request(path: "/user/me")
    }
}
