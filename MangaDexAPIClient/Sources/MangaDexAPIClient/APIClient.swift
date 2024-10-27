//
//  APIClient.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Dependencies
import Foundation
import Get

enum MangaDexServer: CaseIterable, Sendable {
    case production
    case development
}

extension Get.APIClient {
    /// Creates a client for MangaDex API.
    static func mangaDex(server: MangaDexServer = .production) -> Self {
        Self(baseURL: URL(string: server.baseURL)) {
            $0.decoder = .mangaDexAPI
            $0.delegate = MangaDexAPIClientDelegate()
        }
    }
}

private extension MangaDexServer {
    var baseURL: String {
        switch self {
        case .production: "https://api.mangadex.org"
        case .development: "https://api.mangadex.dev"
        }
    }
}

private enum MangaDexAPIClientDependencyKey: DependencyKey {
    typealias Value = APIClient

    static let liveValue: APIClient = .mangaDex()
}

public extension DependencyValues {
    var mangaDexAPIClient: APIClient {
        get { self[MangaDexAPIClientDependencyKey.self] }
        set { self[MangaDexAPIClientDependencyKey.self] = newValue }
    }
}
