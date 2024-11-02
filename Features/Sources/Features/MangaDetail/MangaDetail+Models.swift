//
//  MangaDetail+Models.swift
//  Features
//
//  Created by Long Kim on 1/11/24.
//

import Foundation
import MidoriStorage

public extension MangaDetail {
    struct Manga: Equatable, Sendable {
        public let title: String
        public let alternateTitle: String?
        public let coverImageURL: URL?
    }

    struct Chapter: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let title: String
        public let group: String
    }
}

extension MangaDetail.Manga {
    init(_ entity: MangaEntity) {
        let alternateTitle = entity.alternateTitles.lazy.compactMap { $0.localizedVariants["en"] }.first

        self.init(
            title: entity.title,
            alternateTitle: alternateTitle,
            coverImageURL: entity.currentCover?.imageURLs[.mediumThumbnail]
        )
    }
}

extension MangaDetail.Chapter {
    init(_ entity: ChapterEntity) {
        self.init(
            id: entity.id,
            title: entity.combinedTitle,
            group: entity.groupName
        )
    }
}
