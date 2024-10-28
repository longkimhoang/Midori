//
//  MangaEntity.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Foundation
import SwiftData

@Model
public final class MangaEntity {
    #Unique<MangaEntity>([\.id])
    #Index<MangaEntity>([\.id], [\.createdAt, \.followCount])

    public var id: UUID
    public var title: String
    public var createdAt: Date
    public var alternateTitles: [LocalizedString]
    public var synopsis: LocalizedString?
    public var followCount: Int

    public init(
        id: UUID,
        title: String,
        createdAt: Date,
        alternateTitles: [LocalizedString] = [],
        synopsis: LocalizedString? = nil,
        followCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.alternateTitles = alternateTitles
        self.synopsis = synopsis
        self.followCount = followCount
    }

    @Relationship public var author: AuthorEntity?
    @Relationship public var artist: AuthorEntity?
    @Relationship public var chapters: [ChapterEntity] = []
    @Relationship public var currentCover: MangaCoverEntity?
    @Relationship(inverse: \MangaCoverEntity.manga) public var covers: [MangaCoverEntity] = []
}
