//
//  HomeViewModel+Models.swift
//  ViewModels
//
//  Created by Long Kim on 8/11/24.
//

import Algorithms
import Foundation
import IdentifiedCollections
import MidoriStorage

extension HomeViewModel {
    public struct Manga: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let title: String
        public let subtitle: String?
        public let coverImageURL: URL?
    }

    @dynamicMemberLookup
    public struct LatestChapter: Identifiable, Equatable, Sendable {
        public struct MangaInfo: Equatable, Sendable {
            public let id: UUID
            public let title: String
        }

        public let chapter: Chapter
        public let mangaInfo: MangaInfo
        public let coverImageURL: URL?

        public var id: UUID {
            chapter.id
        }

        public subscript<T>(dynamicMember keyPath: KeyPath<Chapter, T>) -> T {
            chapter[keyPath: keyPath]
        }
    }

    public struct HomeData: Equatable {
        public var popularMangas: IdentifiedArrayOf<Manga>
        public var latestChapters: IdentifiedArrayOf<LatestChapter>
        public var recentlyAddedMangas: IdentifiedArrayOf<Manga>

        public init(
            popularMangas: IdentifiedArrayOf<Manga> = [],
            latestChapters: IdentifiedArrayOf<LatestChapter> = [],
            recentlyAddedMangas: IdentifiedArrayOf<Manga> = []
        ) {
            self.popularMangas = popularMangas
            self.latestChapters = latestChapters
            self.recentlyAddedMangas = recentlyAddedMangas
        }

        public var isEmpy: Bool {
            popularMangas.isEmpty && latestChapters.isEmpty && recentlyAddedMangas.isEmpty
        }
    }

    public enum NavigationDestination: Equatable {
        case mangaDetail(UUID)
        case reader(UUID)
    }
}

extension HomeViewModel.Manga {
    init(_ entity: MangaEntity) {
        self.init(
            id: entity.id,
            title: entity.title,
            subtitle: entity.combinedAuthors,
            coverImageURL: entity.currentCover?.imageURLs[.smallThumbnail]
        )
    }
}

extension HomeViewModel.LatestChapter {
    init?(_ entity: ChapterEntity) {
        guard let manga = entity.manga else {
            return nil
        }

        self.init(
            chapter: .init(entity),
            mangaInfo: .init(id: manga.id, title: manga.title),
            coverImageURL: entity.manga?.currentCover?.imageURLs[.smallThumbnail]
        )
    }
}
