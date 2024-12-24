//
//  HomeViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 8/11/24.
//

import Combine
import Dependencies
import Foundation
import IdentifiedCollections
import MidoriServices
import MidoriStorage
import SwiftData

@MainActor
public final class HomeViewModel {
    @Dependency(\.modelContainer) private var modelContainer
    @Dependency(\.mangaService) private var mangaService
    @Dependency(\.chapterService) private var chapterService

    private lazy var navigationDestinationSubject = PassthroughSubject<NavigationDestination, Never>()

    @Published public var isLoading: Bool = false
    @Published public var data = HomeData()
    public lazy var navigationDestinationPublisher = navigationDestinationSubject.eraseToAnyPublisher()

    public init() {}

    public func loadHomeDataFromStorage() throws {
        let context = modelContainer.mainContext
        let popularMangas = try context.fetch(MangaEntity.popular()).map(Manga.init)
        let latestChapters = try context.fetch(ChapterEntity.latest(limit: 64))
            .uniqued(on: \.manga?.id).compactMap(Chapter.init)
        let recentlyAddedMangas = try context.fetch(MangaEntity.recentlyAdded(limit: 15)).map(Manga.init)

        data = HomeData(
            popularMangas: IdentifiedArray(uniqueElements: popularMangas),
            latestChapters: IdentifiedArray(uniqueElements: latestChapters),
            recentlyAddedMangas: IdentifiedArray(uniqueElements: recentlyAddedMangas)
        )
    }

    public func fetchHomeData() async throws {
        isLoading = true
        defer { isLoading = false }

        try await withThrowingDiscardingTaskGroup { [mangaService, chapterService] group in
            group.addTask { try await mangaService.syncPopularMangas() }
            group.addTask { try await chapterService.syncLatestChapters() }
            group.addTask { try await mangaService.syncRecentlyAddedMangas(limit: 15) }
        }
        try loadHomeDataFromStorage()
    }

    public func latestUpdatesButtonTapped() {}

    public func recentlyAddedButtonTapped() {}

    public func mangaSelected(id: UUID) {
        navigationDestinationSubject.send(.mangaDetail(id))
    }

    public func latestChapterSelected(id: UUID) {
        navigationDestinationSubject.send(.reader(id))
    }
}
