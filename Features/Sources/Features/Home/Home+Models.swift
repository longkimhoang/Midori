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
    }

    struct Chapter: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let title: String
        public let group: String?
    }
}

extension Home.Manga {
    init(_ entity: MangaEntity) {
        self.init(
            id: entity.id,
            title: entity.title,
            subtitle: entity.subtitle
        )
    }
}

extension Home.Chapter {
    init(_ entity: ChapterEntity) {
        self.init(
            id: entity.id,
            title: entity.chapterName,
            group: entity.scanlationGroup?.name
        )
    }
}

private extension MangaEntity {
    var subtitle: String? {
        guard let author else { return nil }
        return [author.name, artist?.name].compacted().formatted(.list(type: .and, width: .narrow))
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
