//
//  MangaCover.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Foundation
import GRDB

struct MangaCover: Codable, Identifiable, Sendable {
    let id: UUID
    let mangaID: UUID
    let fileName: String
    // If nil, cover belongs to a manga without volumes, or an unreleased volume.
    let volume: String?
}

extension MangaCover: FetchableRecord, PersistableRecord {
    private static let manga = belongsTo(Manga.self)

    var manga: QueryInterfaceRequest<Manga> {
        request(for: MangaCover.manga)
    }
}
