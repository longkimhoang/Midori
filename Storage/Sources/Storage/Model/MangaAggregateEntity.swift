//
//  MangaAggregateEntity.swift
//  Storage
//
//  Created by Long Kim on 30/11/24.
//

import Foundation
import IdentifiedCollections
import SwiftData

@Model
public final class MangaAggregateEntity {
    public struct Volume: Codable {
        public let volume: String
        public let chapters: [Chapter]

        public init(volume: String, chapters: [Chapter]) {
            self.volume = volume
            self.chapters = chapters
        }
    }

    public struct Chapter: Codable {
        public let chapter: String
        public let id: UUID
        public let others: [UUID]

        public init(chapter: String, id: UUID, others: [UUID]) {
            self.chapter = chapter
            self.id = id
            self.others = others
        }
    }

    #Unique<MangaAggregateEntity>([\.manga, \.scanlationGroup])
    #Index<MangaAggregateEntity>([\.manga, \.scanlationGroup])

    public var volumes: [Volume]
    @Relationship public var manga: MangaEntity?
    @Relationship public var scanlationGroup: ScanlationGroupEntity?

    public init(volumes: [Volume]) {
        self.volumes = volumes
    }
}
