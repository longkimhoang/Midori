//
//  Author.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Foundation
import GRDB

struct Author: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let imageURL: URL?

    init(id: UUID, name: String, imageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}

extension Author: FetchableRecord, PersistableRecord {
    private static let mangas = hasMany(MangaEntity.self)

    /// The mangas contributed to by this author.
    var mangas: QueryInterfaceRequest<MangaEntity> {
        request(for: Author.mangas)
    }
}
