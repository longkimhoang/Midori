//
//  AtHomeEndpoint.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 11/11/24.
//

import Foundation
import Get

public extension MangaDexAPI {
    struct AtHome: Sendable {
        static let path = "/at-home"

        public static func server(chapterID: UUID) -> Server {
            Server(path: path + "/server/\(chapterID.uuidString.lowercased())")
        }
    }
}

public extension MangaDexAPI.AtHome {
    struct Server: Sendable {
        let path: String
    }
}

public extension MangaDexAPI.AtHome.Server {
    func get(forceHTTPS: Bool = false) -> Request<AtHomeServer> {
        var query: [(String, String?)] = []
        if forceHTTPS {
            query.append(("forcePort443", "true"))
        }

        return Request(path: path, query: query)
    }
}
