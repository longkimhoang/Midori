//
//  Chapter.swift
//  Storage
//
//  Created by Long Kim on 18/10/24.
//

import Foundation
import GRDB

struct Chapter: Codable, Identifiable, Sendable {
    let id: UUID
    let mangaID: UUID
    let scanlationGroupID: UUID?
    let volume: String?
    let title: String?
    let chapter: String?
    let readableAt: Date
}

extension Chapter: FetchableRecord, PersistableRecord {
    private static let manga = belongsTo(MangaEntity.self)
    private static let scanlationGroup = belongsTo(ScanlationGroup.self)

    /// The chapter's manga.
    var manga: QueryInterfaceRequest<MangaEntity> {
        request(for: Chapter.manga)
    }

    /// The group that scanlates this chapter.
    var scanlationGroup: QueryInterfaceRequest<ScanlationGroup> {
        request(for: Chapter.scanlationGroup)
    }
}
