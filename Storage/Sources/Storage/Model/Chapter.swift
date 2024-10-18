//
//  Chapter.swift
//  Storage
//
//  Created by Long Kim on 18/10/24.
//

import Foundation
import GRDB

public struct Chapter: Codable, Identifiable, Sendable {
    public let id: UUID
    public let mangaID: UUID
    public let scanlationGroupID: UUID?
    public let volume: String?
    public let title: String?
    public let chapter: String?
    public let readableAt: Date

    public init(
        id: UUID,
        mangaID: UUID,
        scanlationGroupID: UUID?,
        volume: String?,
        title: String?,
        chapter: String?,
        readableAt: Date
    ) {
        self.id = id
        self.mangaID = mangaID
        self.scanlationGroupID = scanlationGroupID
        self.volume = volume
        self.title = title
        self.chapter = chapter
        self.readableAt = readableAt
    }
}

extension Chapter: FetchableRecord, PersistableRecord {
    private static let manga = belongsTo(Manga.self)
    private static let scanlationGroup = belongsTo(ScanlationGroup.self)

    /// The chapter's manga.
    public var manga: QueryInterfaceRequest<Manga> {
        request(for: Chapter.manga)
    }

    /// The group that scanlates this chapter.
    public var scanlationGroup: QueryInterfaceRequest<ScanlationGroup> {
        request(for: Chapter.scanlationGroup)
    }
}
