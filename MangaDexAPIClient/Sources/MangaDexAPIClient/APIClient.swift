//
//  APIClient.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation
import Get

public enum MangaDexServer {
    case production
}

public extension APIClient {
    /// Creates a client for MangaDex API.
    static func mangaDex(server: MangaDexServer = .production) -> APIClient {
        APIClient(baseURL: URL(string: server.baseURL)) {
            $0.decoder = .mangaDexAPI
        }
    }
}

private extension MangaDexServer {
    var baseURL: String {
        switch self {
        case .production: "https://api.mangadex.org"
        }
    }
}
