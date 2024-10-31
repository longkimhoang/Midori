//
//  MangaDetail.swift
//  Features
//
//  Created by Long Kim on 31/10/24.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct MangaDetail {
    @ObservableState
    public struct State: Equatable, Sendable {
        public let mangaID: UUID

        public init(mangaID: UUID) {
            self.mangaID = mangaID
        }
    }

    public enum Action: Equatable, Sendable {
        case fetchManga
        case loadMangaFromStorage
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .fetchManga:
                .none
            case .loadMangaFromStorage:
                .none
            }
        }
    }
}
