//
//  Home.swift
//  Features
//
//  Created by Long Kim on 27/10/24.
//

import Algorithms
import ComposableArchitecture
import MidoriServices
import MidoriStorage
import SwiftData

@Reducer
public struct Home {
    @ObservableState
    public struct State: Equatable {
        public var popularMangas: IdentifiedArrayOf<Manga>
        public var latestChapters: IdentifiedArrayOf<Chapter>
        public var recentlyAddedMangas: IdentifiedArrayOf<Manga>
        public var path = StackState<Path.State>()

        public init(
            popularMangas: IdentifiedArrayOf<Manga> = [],
            latestChapters: IdentifiedArrayOf<Chapter> = [],
            recentlyAddedMangas: IdentifiedArrayOf<Manga> = []
        ) {
            self.popularMangas = popularMangas
            self.latestChapters = latestChapters
            self.recentlyAddedMangas = recentlyAddedMangas
        }
    }

    public enum Action: ViewAction {
        case loadHomeDataFromStorage
        case path(StackActionOf<Path>)
        case view(View)

        public enum View {
            case fetchHomeData
        }
    }

    @Reducer(state: .equatable)
    public enum Path {}

    @Dependency(\.modelContainer) private var modelContainer
    @Dependency(\.mangaService) private var mangaService
    @Dependency(\.chapterService) private var chapterService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.fetchHomeData):
                loadHomeDataFromStorage(state: &state)
                return .run { [mangaService, chapterService] send in
                    try await withThrowingDiscardingTaskGroup { group in
                        group.addTask { try await mangaService.syncPopularMangas() }
                        group.addTask { try await chapterService.syncLatestChapters() }
                        group.addTask { try await mangaService.syncRecentlyAddedMangas(limit: 15, offset: 0) }
                    }
                    await send(.loadHomeDataFromStorage)
                }
            case .loadHomeDataFromStorage:
                loadHomeDataFromStorage(state: &state)
                return .none
            case .path:
                return .none
            }
        }
        ._printChanges()
    }

    private func loadHomeDataFromStorage(state: inout State) {
        let context = ModelContext(modelContainer)

        do {
            let popularMangas = try context.fetch(MangaEntity.popular()).map(Manga.init)
            let latestChapters = try context.fetch(ChapterEntity.latest(limit: 64))
                .uniqued(on: \.manga?.id).map(Chapter.init)
            let recentlyAddedMangas = try context.fetch(MangaEntity.recentlyAdded(limit: 15)).map(Manga.init)

            state.popularMangas = IdentifiedArray(uniqueElements: popularMangas)
            state.latestChapters = IdentifiedArray(uniqueElements: latestChapters)
            state.recentlyAddedMangas = IdentifiedArray(uniqueElements: recentlyAddedMangas)
        } catch {}
    }
}
