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
import OrderedCollections
import SwiftData

@Reducer
public struct MangaDetail {
    @ObservableState
    public struct State: Equatable, Sendable {
        public typealias ChaptersByVolume = OrderedDictionary<Volume, IdentifiedArrayOf<Chapter>>

        public let mangaID: UUID
        public var manga: Manga?
        public var chaptersByVolume: ChaptersByVolume
        public var isDescriptionExpanded: Bool = false

        @ObservationStateIgnored fileprivate var offset: Int = 0

        public init(mangaID: UUID, manga: Manga? = nil, chaptersByVolume: ChaptersByVolume = [:]) {
            self.mangaID = mangaID
            self.manga = manga
            self.chaptersByVolume = chaptersByVolume
        }
    }

    public enum Action: Equatable, Sendable {
        case fetchMangaDetail
        case loadMangaFromStorage
        case expandDescription(_ isExpanded: Bool)
    }

    @Dependency(\.modelContainer) private var modelContainer
    @Dependency(\.mangaService) private var mangaService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchMangaDetail:
                return .run { [mangaID = state.mangaID, mangaService] send in
                    try await mangaService.syncManga(id: mangaID)
                    try await mangaService.syncMangaFeed(id: mangaID, limit: 50, offset: 0)
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
            case let .expandDescription(isExpanded):
                state.isDescriptionExpanded = isExpanded
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

            let chapterEntities = try context.fetch(ChapterEntity.feed(for: state.mangaID))
            state.offset = chapterEntities.count

            var chaptersByVolume = State.ChaptersByVolume()

            for chapterEntity in chapterEntities {
                let chapter = Chapter(chapterEntity)
                let volume = chapterEntity.volume.map(Volume.volume) ?? .none
                chaptersByVolume[volume, default: []].append(chapter)
            }

            chaptersByVolume.sort { $0.key > $1.key }
            state.chaptersByVolume = chaptersByVolume
        } catch {}
    }
}
