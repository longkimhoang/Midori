//
//  ReaderViewModel+Models.swift
//  ViewModels
//
//  Created by Long Kim on 14/11/24.
//

import Foundation
import IdentifiedCollections
import MidoriStorage

public extension ReaderViewModel {
    struct Manga: Equatable {
        public let id: UUID
        public let title: String
        public let coverImageURL: URL?

        public init(id: UUID, title: String, coverImageURL: URL?) {
            self.id = id
            self.title = title
            self.coverImageURL = coverImageURL
        }
    }

    struct ScanlationGroup: Equatable {
        public let id: UUID
        public let name: String
    }

    struct Chapter: Equatable {
        public let title: String
        public let manga: Manga
        public let scanlationGroup: ScanlationGroup

        public init(title: String, manga: Manga, scanlationGroup: ScanlationGroup) {
            self.title = title
            self.manga = manga
            self.scanlationGroup = scanlationGroup
        }
    }

    struct Page: Identifiable, Equatable, Sendable {
        public let id: String
        public let imageURL: URL

        public init(id: String, imageURL: URL) {
            self.id = id
            self.imageURL = imageURL
        }
    }

    struct Aggregate: Equatable, Sendable {
        public enum VolumeIdentifier: Hashable, Sendable {
            case none
            case volume(String)
        }

        public struct Volume: Identifiable, Equatable, Sendable {
            public let id: VolumeIdentifier
            public let chapters: IdentifiedArrayOf<Chapter>
        }

        public struct Chapter: Identifiable, Equatable, Sendable {
            public let id: UUID
            public let chapter: String
        }

        public let volumes: IdentifiedArrayOf<Volume>
    }
}

public extension ReaderViewModel.Chapter {
    init?(_ entity: ChapterEntity) {
        guard let manga = entity.manga, let scanlationGroup = entity.scanlationGroup else {
            return nil
        }

        title = switch (entity.chapter, entity.title) {
        case let (_, .some(title)):
            title
        case let (.some(chapter), _):
            String(localized: "Chapter \(chapter)", bundle: .module)
        default:
            String(localized: "Oneshot", bundle: .module)
        }
        self.manga = ReaderViewModel.Manga(
            id: manga.id,
            title: manga.title,
            coverImageURL: manga.currentCover?.imageURLs[.smallThumbnail]
        )
        self.scanlationGroup = ReaderViewModel.ScanlationGroup(id: scanlationGroup.id, name: scanlationGroup.name)
    }
}

public extension ReaderViewModel.Page {
    init?(_ entity: PageEntity) {
        guard let chapter = entity.chapter else {
            return nil
        }

        let id = "chapterID=\(chapter.id);page=\(entity.pageIndex);quality=\(entity.quality.rawValue)"
        self.init(id: id, imageURL: entity.imageURL)
    }
}

public extension ReaderViewModel.Aggregate {
    init(_ entity: MangaAggregateEntity) {
        var volumes = entity.volumes.map { volume in
            var chapters = volume.chapters.map {
                Chapter(id: $0.id, chapter: $0.chapter)
            }
            chapters.sort(using: KeyPathComparator(\.chapter, order: .reverse))

            return Volume(id: .init(rawValue: volume.volume), chapters: IdentifiedArray(uniqueElements: chapters))
        }
        volumes.sort(using: KeyPathComparator(\.id, order: .reverse))

        self.init(volumes: IdentifiedArray(uniqueElements: volumes))
    }
}

extension ReaderViewModel.Aggregate.VolumeIdentifier: RawRepresentable {
    public typealias RawValue = String

    public init(rawValue: String) {
        if rawValue == "none" {
            self = .none
        } else {
            self = .volume(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .none:
            "none"
        case let .volume(value):
            value
        }
    }
}

extension ReaderViewModel.Aggregate.VolumeIdentifier: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            false
        case (.none, .volume):
            false
        case (.volume, .none):
            true
        case let (.volume(lhs), .volume(rhs)):
            lhs < rhs
        }
    }
}
