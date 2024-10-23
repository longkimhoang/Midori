//
//  MangaInfo.swift
//  Models
//
//  Created by Long Kim on 22/10/24.
//

import Foundation

public struct MangaInfo: Identifiable, Equatable, Decodable, Sendable {
    public struct Manga: Equatable, Decodable, Sendable {
        public let id: UUID
        public let title: String
    }

    public struct Author: Equatable, Decodable, Sendable {
        public let id: UUID
        public let name: String

        public init(id: UUID, name: String) {
            self.id = id
            self.name = name
        }
    }

    public let manga: Manga
    public let author: Author
    public let artist: Author?

    public init(manga: Manga, author: Author, artist: Author?) {
        self.manga = manga
        self.author = author
        self.artist = artist
    }

    public var id: UUID { manga.id }
}
