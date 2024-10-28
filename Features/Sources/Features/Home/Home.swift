//
//  Home.swift
//  Features
//
//  Created by Long Kim on 27/10/24.
//

import ComposableArchitecture
import MidoriServices
import MidoriStorage
import SwiftData

@Reducer
public struct Home {
    @ObservableState
    public struct State: Equatable {
        public var popularMangas: IdentifiedArrayOf<PopularManga>
        public var latestChapters: IdentifiedArrayOf<Chapter>

        public init(
            popularMangas: IdentifiedArrayOf<PopularManga> = [],
            latestChapters: IdentifiedArrayOf<Chapter> = []
        ) {
            self.popularMangas = popularMangas
            self.latestChapters = latestChapters
        }
    }

    public enum Action {
        case fetchHomeData
        case loadHomeDataFromStorage
    }

    @Dependency(\.modelContainer) private var modelContainer
    @Dependency(\.mangaService) private var mangaService
    @Dependency(\.chapterService) private var chapterService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchHomeData:
                loadHomeDataFromStorage(state: &state)
                return .run { [mangaService, chapterService] send in
                    try await withThrowingDiscardingTaskGroup { group in
                        group.addTask { try await mangaService.syncPopularMangas() }
                        group.addTask { try await chapterService.syncLatestChapters() }
                    }
                    await send(.loadHomeDataFromStorage)
                }
            case .loadHomeDataFromStorage:
                loadHomeDataFromStorage(state: &state)
                return .none
            }
        }
    }

    private func loadHomeDataFromStorage(state: inout State) {
        let context = ModelContext(modelContainer)

        do {
            let popularMangas = try context.fetch(MangaEntity.popular())
                .compactMap(PopularManga.init)

            state.popularMangas = IdentifiedArray(uniqueElements: popularMangas)
        } catch {}
    }
}
