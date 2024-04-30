//
//  HomeFeature.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import ComposableArchitecture
import Foundation
import MangaDetailCore
import Networking

@Reducer
public struct HomeFeature: Sendable {
  @ObservableState
  public struct State: Equatable, Sendable {
    @CasePathable @dynamicMemberLookup
    public enum FetchStatus: Equatable, Sendable {
      case pending
      case success(HomeData)
      case failure(reason: String)
    }

    public var fetchStatus: FetchStatus = .pending
    public var path = StackState<Path.State>()

    public init() {}
  }

  public enum Action: Sendable {
    case fetchHomeData
    case homeDataResponse(Result<HomeData, any Error>)
    case mangaTapped(Manga.ID)
    case latestUpdatesButtonTapped
    case recentlyAddedButtonTapped
    case path(StackActionOf<Path>)
  }

  @Reducer(state: .equatable, .sendable, action: .sendable)
  public enum Path {
    case recentlyAdded(RecentlyAddedFeature)
    case manga(MangaDetailFeature)
  }

  @Dependency(\.homeData) var homeData

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchHomeData:
        return .run { send in
          async let popularMangas = try await homeData.retrievePopularMangas()
          async let latestChapters = try await homeData.retrieveLatestChapters()
          async let recentlyAddedMangas = try await homeData.retrieveRecentlyAddedMangas()

          let data = try await HomeData(
            popularMangas: popularMangas,
            latestChapters: latestChapters,
            recentlyAddedMangas: recentlyAddedMangas
          )
          await send(.homeDataResponse(.success(data)))
        } catch: { error, send in
          await send(.homeDataResponse(.failure(error)))
        }
        .animation()
      case let .homeDataResponse(.success(data)):
        state.fetchStatus = .success(data)
        return .none
      case let .homeDataResponse(.failure(error)):
        state.fetchStatus = .failure(reason: error.localizedDescription)
        return .none
      case let .mangaTapped(mangaID):
        state.path.append(.manga(.init(mangaID: mangaID)))
        return .none
      case .latestUpdatesButtonTapped:
        return .none
      case .recentlyAddedButtonTapped:
        state.path.append(.recentlyAdded(.init()))
        return .none
      case .path:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
  }
}
