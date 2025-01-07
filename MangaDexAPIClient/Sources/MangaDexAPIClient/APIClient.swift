//
//  APIClient.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Dependencies
import Foundation
import Get

public enum MangaDexServer: CaseIterable, Sendable {
    case production
    case development
}

extension APIClient {
    /// Creates a client for MangaDex API.
    public static func mangaDex(
        server: MangaDexServer = .production,
        sessionConfiguration: URLSessionConfiguration = .default
    ) -> Self {
        Self(baseURL: URL(string: server.baseURL)) {
            $0.sessionConfiguration = sessionConfiguration
            $0.decoder = .mangaDexAPI
            $0.delegate = MangaDexAPIClientDelegate()
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

private enum MangaDexAPIClientDependencyKey: DependencyKey {
    typealias Value = APIClient

    static let liveValue: APIClient = .mangaDex()
}

extension DependencyValues {
    public var mangaDexAPIClient: APIClient {
        get { self[MangaDexAPIClientDependencyKey.self] }
        set { self[MangaDexAPIClientDependencyKey.self] = newValue }
    }
}
