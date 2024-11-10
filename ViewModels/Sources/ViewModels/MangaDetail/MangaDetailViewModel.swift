//
//  MangaDetailViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 10/11/24.
//

import Combine
import Dependencies
import Foundation
import IdentifiedCollections
import MidoriServices
import MidoriStorage
import OrderedCollections

@MainActor
public final class MangaDetailViewModel {
    public typealias ChaptersByVolume = OrderedDictionary<Volume, IdentifiedArrayOf<Chapter>>

    public enum NavigationDestination {
        case mangaSynopsis
    }

    @Dependency(\.modelContainer) private var modelContainer
    @Dependency(\.mangaService) private var mangaService
    private lazy var navigationDestinationSubject = PassthroughSubject<NavigationDestination, Never>()

    public let mangaID: UUID
    @Published public var manga: Manga?
    @Published public var chaptersByVolume: ChaptersByVolume
    public private(set) lazy var navigationDestinationPublisher = navigationDestinationSubject.eraseToAnyPublisher()

    private var offset: Int = 0

    public init(mangaID: UUID, manga: Manga? = nil, chaptersByVolume: ChaptersByVolume = [:]) {
        self.mangaID = mangaID
        self.manga = manga
        self.chaptersByVolume = chaptersByVolume
    }

    public func loadMangaFromStorage() throws {
        let context = modelContainer.mainContext
        guard let mangaEntity = try context.fetch(MangaEntity.withID(mangaID)).first else {
            return
        }

        manga = Manga(mangaEntity)

        let chapterEntities = try context.fetch(ChapterEntity.feed(for: mangaID))
        offset = chapterEntities.count

        var chaptersByVolume = ChaptersByVolume()

        for chapterEntity in chapterEntities {
            let chapter = Chapter(chapterEntity)
            let volume = chapterEntity.volume.map(Volume.volume) ?? .none
            chaptersByVolume[volume, default: []].append(chapter)
        }

        chaptersByVolume.sort { $0.key > $1.key }
        self.chaptersByVolume = chaptersByVolume
    }

    public func fetchMangaDetail() async throws {
        try await mangaService.syncManga(id: mangaID)
        try await mangaService.syncMangaFeed(id: mangaID, limit: 50, offset: 0)
        try loadMangaFromStorage()
    }

    public func mangaSynopsisExpanded() {
        navigationDestinationSubject.send(.mangaSynopsis)
    }
}
