//
//  MangaEntity.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Foundation
import GRDB

struct MangaEntity: Codable, Identifiable, Equatable, Sendable {
    struct LocalizedTitle: Codable, Equatable, Sendable {
        let language: String
        let value: String
    }

    let id: UUID
    let title: String
    let createdAt: Date
    // Alternate titles in other languages. Not all mangas have this.
    let alternateTitles: [LocalizedTitle]
    let description: [String: String]?
    let followCount: Int
    let coverID: UUID?
    let authorID: UUID?
    let artistID: UUID?

    init(
        id: UUID,
        title: String,
        createdAt: Date,
        alternateTitles: [LocalizedTitle] = [],
        description: [String: String]? = nil,
        followCount: Int = 0,
        coverID: UUID? = nil,
        authorID: UUID? = nil,
        artistID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.alternateTitles = alternateTitles
        self.description = description
        self.followCount = followCount
        self.coverID = coverID
        self.authorID = authorID
        self.artistID = artistID
    }
}

extension MangaEntity: FetchableRecord, PersistableRecord {
    static let databaseTableName = "manga"

    static let authorForeignKey = ForeignKey(["authorId"])
    static let artistForeignKey = ForeignKey(["artistId"])

    static let latestCover = hasOne(MangaCover.self, key: "coverId")
    static let covers = hasMany(MangaCover.self)
    static let author = belongsTo(Author.self, key: "author", using: authorForeignKey)
    static let artist = belongsTo(Author.self, key: "artist", using: artistForeignKey)
    static let chapters = hasMany(Chapter.self)

    /// The latest cover of the manga, if available.
    var latestCover: QueryInterfaceRequest<MangaCover> {
        request(for: MangaEntity.latestCover)
    }

    /// All covers of the manga.
    var covers: QueryInterfaceRequest<MangaCover> {
        request(for: MangaEntity.covers)
    }

    /// The author of the manga.
    var author: QueryInterfaceRequest<Author> {
        request(for: MangaEntity.author)
    }

    /// The artist of the manga.
    var artist: QueryInterfaceRequest<Author> {
        request(for: MangaEntity.artist)
    }

    /// The manga's chapters.
    var chapters: QueryInterfaceRequest<Chapter> {
        request(for: MangaEntity.chapters)
    }
}
