//
//  AuthorEntity.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Foundation
import SwiftData

@Model
public final class AuthorEntity {
    #Unique<AuthorEntity>([\.id])

    public var id: UUID
    public var name: String
    public var imageURL: URL?

    public init(id: UUID, name: String, imageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }

    @Relationship(inverse: \MangaEntity.author) public var mangasAsAuthor: [MangaEntity] = []
    @Relationship(inverse: \MangaEntity.artist) public var mangasAsAritst: [MangaEntity] = []
}
