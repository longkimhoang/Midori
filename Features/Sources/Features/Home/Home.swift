//
//  Home.swift
//  Features
//
//  Created by Long Kim on 27/10/24.
//

import Algorithms
import ComposableArchitecture
import Foundation
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

    public enum Action: Equatable {
        case fetchHomeData
        case loadHomeDataFromStorage
        case latestUpdatesButtonTapped
        case recentlyAddedButtonTapped
        case mangaSelected(UUID)
        case path(StackActionOf<Path>)
    }

    @Reducer(state: .equatable, action: .equatable)
    public enum Path {
        case mangaDetail(MangaDetail)
    }

    @Dependency(\.mangaService) private var mangaService
    @Dependency(\.chapterService) private var chapterService

    private let context: ModelContext

    public init() {
        @Dependency(\.modelContainer) var modelContainer
        context = ModelContext(modelContainer)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchHomeData:
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
            case .latestUpdatesButtonTapped:
                return .none
            case .recentlyAddedButtonTapped:
                return .none
            case let .mangaSelected(mangaID):
                let mangaDetail = MangaDetail.State(mangaID: mangaID)
                state.path.append(.mangaDetail(mangaDetail))
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        ._printChanges()
    }

    private func loadHomeDataFromStorage(state: inout State) {
        do {
            let popularMangas = try context.fetch(MangaEntity.popular()).map(Manga.init)
            let latestChapters = try context.fetch(ChapterEntity.latest(limit: 64))
                .uniqued(on: \.manga?.id).compactMap(Chapter.init)
            let recentlyAddedMangas = try context.fetch(MangaEntity.recentlyAdded(limit: 15)).map(Manga.init)

            state.popularMangas = IdentifiedArray(uniqueElements: popularMangas)
            state.latestChapters = IdentifiedArray(uniqueElements: latestChapters)
            state.recentlyAddedMangas = IdentifiedArray(uniqueElements: recentlyAddedMangas)
        } catch {}
    }
}
