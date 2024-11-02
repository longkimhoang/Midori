//
//  MangaDetail.swift
//  Features
//
//  Created by Long Kim on 31/10/24.
//

import ComposableArchitecture
import Foundation
import MidoriServices
import MidoriStorage
import SwiftData

@Reducer
public struct MangaDetail {
    @ObservableState
    public struct State: Equatable, Sendable {
        public let mangaID: UUID
        public var manga: Manga?
        public var chapters: IdentifiedArrayOf<Chapter> = []

        public init(mangaID: UUID, manga: Manga? = nil, chapters: IdentifiedArrayOf<Chapter> = []) {
            self.mangaID = mangaID
            self.manga = manga
            self.chapters = chapters
        }
    }

    public enum Action: Equatable, Sendable {
        case fetchMangaDetail
        case loadMangaFromStorage
    }

    @Dependency(\.modelContainer) private var modelContainer
    @Dependency(\.mangaService) private var mangaService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchMangaDetail:
                return .run { [mangaID = state.mangaID, mangaService] send in
                    try await mangaService.syncManga(id: mangaID)
                    await send(.loadMangaFromStorage)
                } catch: { [hasMangaLocally = state.manga != nil] error, _ in
                    switch error {
                    case MangaServiceError.mangaNotFound where !hasMangaLocally:
                        // TODO: Show error
                        break
                    default:
                        break
                    }
                }
            case .loadMangaFromStorage:
                loadMangaDetailFromStorage(state: &state)
                return .none
            }
        }
    }

    private func loadMangaDetailFromStorage(state: inout State) {
        let context = ModelContext(modelContainer)
        do {
            guard let mangaEntity = try context.fetch(MangaEntity.withID(state.mangaID)).first else {
                return
            }

            state.manga = Manga(mangaEntity)

            let chapters = try context.fetch(ChapterEntity.feed(for: state.mangaID))
            state.chapters = IdentifiedArrayOf(uniqueElements: chapters.map(Chapter.init))
        } catch {}
    }
}
