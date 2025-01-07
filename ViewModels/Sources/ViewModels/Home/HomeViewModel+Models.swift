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

    public struct Chapter: Identifiable, Equatable, Sendable {
        public struct MangaInfo: Equatable, Sendable {
            public let id: UUID
            public let title: String
        }

        public let id: UUID
        public let mangaInfo: MangaInfo
        public let chapter: String
        public let group: String
        public let coverImageURL: URL?
    }

    public struct HomeData: Equatable {
        public var popularMangas: IdentifiedArrayOf<Manga>
        public var latestChapters: IdentifiedArrayOf<Chapter>
        public var recentlyAddedMangas: IdentifiedArrayOf<Manga>

        public init(
            popularMangas: IdentifiedArrayOf<Manga> = [],
            latestChapters: IdentifiedArrayOf<Chapter> = [],
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

extension HomeViewModel.Chapter {
    init?(_ entity: ChapterEntity) {
        guard let manga = entity.manga else { return nil }

        self.init(
            id: entity.id,
            mangaInfo: .init(id: manga.id, title: manga.title),
            chapter: entity.combinedTitle(),
            group: entity.groupName,
            coverImageURL: entity.manga?.currentCover?.imageURLs[.smallThumbnail]
        )
    }
}
