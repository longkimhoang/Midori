//
//  Home+Models.swift
//  Features
//
//  Created by Long Kim on 27/10/24.
//

import Algorithms
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
            subtitle: entity.subtitle,
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
            chapter: entity.chapterName,
            group: entity.scanlationGroup?.name ?? String(localized: "No group", bundle: .module),
            coverImageURL: entity.manga?.currentCover?.imageURLs[.smallThumbnail]
        )
    }
}

private extension MangaEntity {
    var subtitle: String? {
        guard let author else { return nil }
        return [author.name, artist?.name].compacted().uniqued().formatted(.list(type: .and, width: .narrow))
    }
}

private extension ChapterEntity {
    var chapterName: String {
        let localizedChapter = chapter.map {
            String(localized: "Ch. \($0)", bundle: .module, comment: "Shortform for chapter")
        }

        let localizedVolume = volume.map {
            String(localized: "Vol. \($0)", bundle: .module, comment: "Shortform for volume")
        }

        let name = [localizedVolume, localizedChapter, title].compacted()
            .joined(separator: " - ")

        return name.isEmpty ? String(localized: "Oneshot", bundle: .module) : name
    }
}
