//
//  Home+Models.swift
//  Features
//
//  Created by Long Kim on 27/10/24.
//

import Algorithms
import Dependencies
import Foundation
import MidoriStorage

public extension Home {
    struct Manga: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let title: String
        public let subtitle: String?
        public let coverImageURL: URL?
    }

    struct Chapter: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let manga: String
        public let chapter: String
        public let group: String
        public let coverImageURL: URL?
    }
}

extension Home.Manga {
    init(_ entity: MangaEntity) {
        self.init(
            id: entity.id,
            title: entity.title,
            subtitle: entity.combinedAuthors,
            coverImageURL: entity.currentCover?.imageURLs[.smallThumbnail]
        )
    }
}

extension Home.Chapter {
    init?(_ entity: ChapterEntity) {
        guard let manga = entity.manga else { return nil }

        self.init(
            id: entity.id,
            manga: manga.title,
            chapter: entity.combinedTitle(),
            group: entity.groupName,
            coverImageURL: entity.manga?.currentCover?.imageURLs[.smallThumbnail]
        )
    }
}
