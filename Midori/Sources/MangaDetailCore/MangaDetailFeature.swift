//
//  MangaDetailFeature.swift
//
//
//  Created by Long Kim on 30/4/24.
//

import ComposableArchitecture
import Foundation
import ReaderCore

@Reducer
public struct MangaDetailFeature: Sendable {
  @ObservableState
  public struct State: Equatable, Sendable {
    @CasePathable @dynamicMemberLookup
    public enum FetchStatus: Equatable, Sendable {
      case pending
      case success(MangaFeed)
      case failure(reason: String)
    }

    public let mangaID: UUID
    public var fetchStatus: FetchStatus = .pending
    @Presents public var reader: ReaderFeature.State?

    public init(mangaID: UUID) {
      self.mangaID = mangaID
    }
  }

  public enum Action: Sendable {
    case fetchMangaFeed
    case mangaFeedResponse(Result<MangaFeed, any Error>)
    case initialChaptersResponse(IdentifiedArrayOf<Chapter>)
    case selectChapter(UUID)
    case reader(PresentationAction<ReaderFeature.Action>)
  }

  @Dependency(\.mangaFeed) private var mangaFeed

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchMangaFeed:
        let mangaID = state.mangaID
        return .run { send in
          guard let initialFeed = try await mangaFeed.fetchFeedFromStorage(mangaID: mangaID) else {
            return
          }

          await send(.mangaFeedResponse(.success(initialFeed)))

          let chapters = try await mangaFeed.fetchChapters(mangaID: mangaID, offset: nil)
          await send(.initialChaptersResponse(chapters))
        }
      case let .mangaFeedResponse(.success(mangaFeed)):
        state.fetchStatus = .success(mangaFeed)
        return .none
      case let .mangaFeedResponse(.failure(error)):
        state.fetchStatus = .failure(reason: error.localizedDescription)
        return .none
      case let .initialChaptersResponse(chapters):
        state.fetchStatus.success?.chapters = chapters
        return .none
      case let .selectChapter(chapterID):
        state.reader = .init(chapterID: chapterID)
        return .none
      case .reader:
        return .none
      }
    }
    .ifLet(\.$reader, action: \.reader) {
      ReaderFeature()
    }
  }
}
