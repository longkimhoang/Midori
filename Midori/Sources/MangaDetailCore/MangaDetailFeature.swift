//
//  MangaDetailFeature.swift
//
//
//  Created by Long Kim on 30/4/24.
//

import ComposableArchitecture
import Foundation

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

    public init(mangaID: UUID) {
      self.mangaID = mangaID
    }
  }

  public enum Action: Sendable {
    case fetchMangaFeed
    case mangaFeedResponse(Result<MangaFeed, any Error>)
  }

  @Dependency(\.mangaFeed) private var mangaFeed

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchMangaFeed:
        let mangaID = state.mangaID
        return .run { send in
          if let initialFeed = try await mangaFeed.fetchFeedFromStorage(mangaID: mangaID) {
            await send(.mangaFeedResponse(.success(initialFeed)))
          }
        }
      case let .mangaFeedResponse(.success(mangaFeed)):
        state.fetchStatus = .success(mangaFeed)
        return .none
      case let .mangaFeedResponse(.failure(error)):
        state.fetchStatus = .failure(reason: error.localizedDescription)
        return .none
      }
    }
  }
}
