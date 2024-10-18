//
//  MangaCover.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Foundation
import GRDB

public struct MangaCover: Codable, Identifiable, Sendable {
    public let id: UUID
    public let mangaID: UUID
    public let fileName: String
    // If nil, cover belongs to a manga without volumes, or an unreleased volume.
    public let volume: String?

    public init(id: UUID, mangaID: UUID, fileName: String, volume: String?) {
        self.id = id
        self.mangaID = mangaID
        self.fileName = fileName
        self.volume = volume
    }
}

extension MangaCover: FetchableRecord, PersistableRecord {
    private static let manga = belongsTo(Manga.self)

    public var manga: QueryInterfaceRequest<Manga> {
        request(for: MangaCover.manga)
    }
}
