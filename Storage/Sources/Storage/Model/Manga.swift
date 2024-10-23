//
//  Manga.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Foundation
import GRDB

public struct Manga: Codable, Identifiable, Sendable {
    public struct AlternateTitle: Codable, Equatable, Sendable {
        public let language: String
        public let value: String

        public init(language: String, value: String) {
            self.language = language
            self.value = value
        }
    }

    public let id: UUID
    public let title: String
    public let createdAt: Date
    // Alternate titles in other languages. Not all mangas have this.
    public let alternateTitles: [AlternateTitle]
    public let coverId: UUID?
    public let authorID: UUID?
    public let artistID: UUID?

    public init(
        id: UUID,
        title: String,
        createdAt: Date,
        alternateTitles: [AlternateTitle] = [],
        coverId: UUID? = nil,
        authorID: UUID? = nil,
        artistID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.alternateTitles = alternateTitles
        self.coverId = coverId
        self.authorID = authorID
        self.artistID = artistID
    }
}

extension Manga: FetchableRecord, PersistableRecord {
    // Foreign keys
    private static let authorForeignKey = ForeignKey(["authorId"])
    private static let artistForeignKey = ForeignKey(["artistId"])

    public static let latestCover = hasOne(MangaCover.self, key: "coverId")
    public static let covers = hasMany(MangaCover.self)
    public static let author = belongsTo(Author.self, key: "author", using: authorForeignKey)
    public static let artist = belongsTo(Author.self, key: "artist", using: artistForeignKey)
    public static let chapters = hasMany(Chapter.self)

    /// The latest cover of the manga, if available.
    public var latestCover: QueryInterfaceRequest<MangaCover> {
        request(for: Manga.latestCover)
    }

    /// All covers of the manga.
    public var covers: QueryInterfaceRequest<MangaCover> {
        request(for: Manga.covers)
    }

    /// The author of the manga.
    public var author: QueryInterfaceRequest<Author> {
        request(for: Manga.author)
    }

    /// The artist of the manga.
    public var artist: QueryInterfaceRequest<Author> {
        request(for: Manga.artist)
    }

    /// The manga's chapters.
    public var chapters: QueryInterfaceRequest<Chapter> {
        request(for: Manga.chapters)
    }
}
