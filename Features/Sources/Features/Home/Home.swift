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

        public init(popularMangas: IdentifiedArrayOf<PopularManga> = []) {
            self.popularMangas = popularMangas
        }
    }

    public enum Action {
        case fetchHomeData
        case loadHomeDataFromStorage
    }

    @Dependency(\.modelContainer) private var modelContainer
    @Dependency(\.mangaService) private var mangaService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchHomeData:
                loadHomeDataFromStorage(state: &state)
                return .run { [mangaService] send in
                    try await mangaService.syncPopularMangas()
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
