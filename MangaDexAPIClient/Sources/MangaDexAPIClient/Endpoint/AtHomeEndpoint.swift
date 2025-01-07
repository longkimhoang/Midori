//
//  AtHomeEndpoint.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 11/11/24.
//

import Foundation
import Get

extension MangaDexAPI {
    public struct AtHome: Sendable {
        static let path = "/at-home"

        public static func server(chapterID: UUID) -> Server {
            Server(path: path + "/server/\(chapterID.uuidString.lowercased())")
        }
    }
}

extension MangaDexAPI.AtHome {
    public struct Server: Sendable {
        let path: String
    }
}

extension MangaDexAPI.AtHome.Server {
    public func get(forceHTTPS: Bool = false) -> Request<AtHomeServer> {
        var query: [(String, String?)] = []
        if forceHTTPS {
            query.append(("forcePort443", "true"))
        }

        return Request(path: path, query: query)
    }
}
