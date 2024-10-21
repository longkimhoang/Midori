//
//  APIClient.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation
import Get

public enum MangaDexServer: CaseIterable, Sendable {
    case production
    case development
}

public extension APIClient {
    /// Creates a client for MangaDex API.
    static func mangaDex(server: MangaDexServer = .production) -> APIClient {
        APIClient(baseURL: URL(string: server.baseURL)) {
            $0.decoder = .mangaDexAPI
        }
    }
}

extension MangaDexServer {
    var baseURL: String {
        switch self {
        case .production: "https://api.mangadex.org"
        case .development: "https://api.mangadex.dev"
        }
    }
}
