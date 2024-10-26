//
//  ChapterEntity.swift
//  Storage
//
//  Created by Long Kim on 18/10/24.
//

import Foundation
import SwiftData

@Model
public final class ChapterEntity {
    #Unique<ChapterEntity>([\.id])

    public var id: UUID
    public var volume: String?
    public var title: String?
    public var chapter: String?
    public var readableAt: Date

    public init(
        id: UUID,
        volume: String? = nil,
        title: String? = nil,
        chapter: String? = nil,
        readableAt: Date
    ) {
        self.id = id
        self.volume = volume
        self.title = title
        self.chapter = chapter
        self.readableAt = readableAt
    }

    @Relationship public var manga: MangaEntity?
    @Relationship public var scanlationGroup: ScanlationGroupEntity?
}
