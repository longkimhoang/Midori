//
//  AtHomeServer.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 11/11/24.
//

import Foundation

public struct AtHomeServer: Decodable, Sendable {
    public struct Chapter: Decodable, Sendable {
        public let hash: String
        public let data: [String]
        public let dataSaver: [String]
    }

    enum CodingKeys: String, CodingKey {
        case baseURL = "baseUrl"
        case chapter
    }

    public let baseURL: URL
    public let chapter: Chapter
}
