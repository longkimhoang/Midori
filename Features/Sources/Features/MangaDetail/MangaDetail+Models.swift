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

    enum Volume: Hashable, Sendable {
        case none
        case volume(String)

        public var localizedDescription: String {
            switch self {
            case .none:
                String(localized: "No volume", bundle: .module)
            case let .volume(volume):
                String(localized: "Volume \(volume)", bundle: .module)
            }
        }
    }
}

extension MangaDetail.Volume: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        /// In the context of a manga, `none` means an unreleased volume, thus has the highest order.
        switch (lhs, rhs) {
        case (.none, .none):
            false
        case (.volume, .none):
            true
        case (.none, .volume):
            false
        case let (.volume(lhs), .volume(rhs)):
            lhs < rhs
        }
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
            title: entity.combinedTitle(includingVolume: false),
            group: entity.groupName
        )
    }
}
