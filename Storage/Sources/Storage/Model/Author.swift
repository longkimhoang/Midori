//
//  Author.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Foundation
import GRDB

public struct Author: Codable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let imageURL: URL?

    public init(id: UUID, name: String, imageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}

extension Author: FetchableRecord, PersistableRecord {
    private static let mangas = hasMany(Manga.self)

    /// The mangas contributed to by this author.
    public var mangas: QueryInterfaceRequest<Manga> {
        request(for: Author.mangas)
    }
}
