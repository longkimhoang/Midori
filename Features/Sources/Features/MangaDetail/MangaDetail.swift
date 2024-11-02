//
//  MangaDetail.swift
//  Features
//
//  Created by Long Kim on 31/10/24.
//

import ComposableArchitecture
import Foundation
import MidoriStorage
import SwiftData

@Reducer
public struct MangaDetail {
    @ObservableState
    public struct State: Equatable, Sendable {
        public let mangaID: UUID
        public var manga: Manga?

        public init(mangaID: UUID, manga _: Manga? = nil) {
            self.mangaID = mangaID
        }
    }

    public enum Action: Equatable, Sendable {
        case fetchManga
        case loadMangaFromStorage
    }

    private let context: ModelContext

    public init() {
        @Dependency(\.modelContainer) var modelContainer
        context = ModelContext(modelContainer)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchManga:
                return .run { _ in
                } catch: { _, _ in
                }
            case .loadMangaFromStorage:
                loadMangaDetailFromStorage(state: &state)
                return .none
            }
        }
    }

    private func loadMangaDetailFromStorage(state: inout State) {
        do {
            guard let mangaEntity = try context.fetch(MangaEntity.withID(state.mangaID)).first else {
                return
            }

            state.manga = Manga(mangaEntity)
        } catch {}
    }
}
