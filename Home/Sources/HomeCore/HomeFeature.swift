//
//  HomeFeature.swift
//
//
//  Created by Long Kim on 10/3/24.
//

import Collections
import ComposableArchitecture
import Database
import Foundation

@CasePathable
@dynamicMemberLookup
public enum HomeDataFetchStatus {
  case loading
  case success(HomeData)
  case failure(Error)
}

@Reducer
public struct HomeFeature {
  @ObservableState
  public struct State {
    public typealias FetchStatus = HomeDataFetchStatus
    public var fetchStatus: FetchStatus = .loading
    public var isRefreshing: Bool = false
    public var path = StackState<Path.State>()

    public init() {}
  }

  public enum Action: ViewAction {
    case homeDataResponse(HomeData)
    case homeDataFailure(Error)
    case path(StackAction<Path.State, Path.Action>)
    case view(View)

    public enum View {
      case fetchPopularMangas
    }
  }

  public init() {}

  @Dependency(\.popularMangas) var popularMangas
  @Dependency(\.latestChapters) var latestChapters
  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.fetchPopularMangas):
        state.isRefreshing = true
        return .run { send in
          async let popularMangas = try await popularMangas.fetch()
          async let latestChapters = try await latestChapters.fetch()
          async let recentlyAddedMangas = try await recentlyAddedMangas.fetch()

          let data = try await HomeData(
            popularMangas: IdentifiedArray(uniqueElements: popularMangas),
            latestChapters: IdentifiedArray(uniqueElements: latestChapters),
            recentlyAddedMangas: IdentifiedArray(uniqueElements: recentlyAddedMangas)
          )
          await send(.homeDataResponse(data))
        } catch: { error, send in
          await send(.homeDataFailure(error))
        }
      case let .homeDataResponse(data):
        state.isRefreshing = false
        state.fetchStatus = .success(data)
        return .none
      case let .homeDataFailure(error):
        state.isRefreshing = false
        state.fetchStatus = .failure(error)
        return .none
      case let .path(.push(id: id, state: .latestUpdatesDetail)):
        return LatestUpdatesDetailFeature().reduce(
          into: &state.path[id: id]![keyPath: \.latestUpdatesDetail]!,
          action: .view(.fetchInitialChapters)
        ).map {
          Action.path(.element(id: id, action: .latestUpdatesDetail($0)))
        }
      case let .path(.push(id: id, state: .recentlyAddedDetail)):
        if let data = state.fetchStatus.success {
          state.path[id: id]?.recentlyAddedDetail?.mangaList.mangas = data.recentlyAddedMangas
        }
        return .none
      case .path:
        return .none
      }
    }
    .forEach(\.path, action: \.path) {
      Path()
    }
  }
}

extension HomeFeature {
  @Reducer
  public struct Path {
    @ObservableState
    public enum State {
      case latestUpdatesDetail(LatestUpdatesDetailFeature.State)
      case recentlyAddedDetail(RecentlyAddedDetailFeature.State)
    }

    public enum Action {
      case latestUpdatesDetail(LatestUpdatesDetailFeature.Action)
      case recentlyAddedDetail(RecentlyAddedDetailFeature.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: \.latestUpdatesDetail, action: \.latestUpdatesDetail) {
        LatestUpdatesDetailFeature()
      }

      Scope(state: \.recentlyAddedDetail, action: \.recentlyAddedDetail) {
        RecentlyAddedDetailFeature()
      }
    }
  }
}
