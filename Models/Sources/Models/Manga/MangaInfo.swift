//
//  MangaInfo.swift
//  Models
//
//  Created by Long Kim on 22/10/24.
//

import Foundation

public struct MangaInfo: Identifiable, Equatable, Decodable, Sendable {
    public struct AuthorInfo: Equatable, Decodable, Sendable {
        public let id: UUID
        public let name: String

        public init(id: UUID, name: String) {
            self.id = id
            self.name = name
        }
    }

    public let id: UUID
    public let title: String
    public let author: AuthorInfo
    public let artist: AuthorInfo?

    public init(id: UUID, title: String, author: AuthorInfo, artist: AuthorInfo?) {
        self.id = id
        self.title = title
        self.author = author
        self.artist = artist
    }
}
