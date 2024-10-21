//
//  Entity+Relationships.swift
//
//
//  Created by Long Kim on 21/10/24.
//

import Foundation

public extension Entity {
    /// Returns a relationship with the specified type, if available.
    func relationship<T: Relationship>(_: T.Type = T.self) -> T? {
        relationships.lazy.compactMap { $0 as? T }.first
    }
}

// MARK: - Relationships

public struct CoverRelationship: Relationship {
    public typealias Referenced = Cover

    public let id: UUID
    public let attributes: Cover.Attributes?
}

public struct MangaRelationship: Relationship {
    public typealias Referenced = Manga

    public let id: UUID
    public let attributes: Manga.Attributes?
}

public struct AuthorRelationship: Relationship {
    public typealias Referenced = Author

    public let id: UUID
    public let attributes: Author.Attributes?
}

public struct ArtistRelationship: Relationship {
    public typealias Referenced = Author

    public let id: UUID
    public let attributes: Author.Attributes?
}

public struct ScanlationGroupRelationship: Relationship {
    public typealias Referenced = ScanlationGroup

    public let id: UUID
    public let attributes: ScanlationGroup.Attributes?
}
