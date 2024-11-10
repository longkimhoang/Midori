//
//  MangaDetailViewModel+Models.swift
//  ViewModels
//
//  Created by Long Kim on 10/11/24.
//

import Dependencies
import Foundation
import MidoriStorage

public extension MangaDetailViewModel {
    struct Manga: Equatable, Sendable {
        public let title: String
        public let alternateTitle: String?
        public let subtitle: AttributedString?
        public let synopsis: String?
        public let coverImageURL: URL?
        public let rating: Double
    }

    struct Chapter: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let title: String
        public let group: String
        public let readableAt: String
    }

    enum Volume: Hashable, Identifiable, Sendable {
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

        public var id: Self { self }
    }
}

extension MangaDetailViewModel.Volume: Comparable {
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

extension MangaDetailViewModel.Manga {
    init(_ entity: MangaEntity) {
        let alternateTitle = entity.alternateTitles.lazy.compactMap { $0.localizedVariants["en"] }.first
        let subtitle = entity.combinedAuthors.map { AttributedString($0) }

        self.init(
            title: entity.title,
            alternateTitle: alternateTitle,
            subtitle: subtitle,
            synopsis: entity.synopsis.map { $0["en"] },
            coverImageURL: entity.currentCover?.imageURLs[.mediumThumbnail],
            rating: entity.rating
        )
    }
}

extension MangaDetailViewModel.Chapter {
    init(_ entity: ChapterEntity) {
        @Dependency(\.date.now) var now
        let readableAtFormat = Date.AnchoredRelativeFormatStyle(
            anchor: entity.readableAt,
            presentation: .numeric,
            capitalizationContext: .standalone
        )

        self.init(
            id: entity.id,
            title: entity.combinedTitle(includingVolume: false),
            group: entity.groupName,
            readableAt: readableAtFormat.format(now)
        )
    }
}
