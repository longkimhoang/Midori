//
//  HomeFeature.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import ComposableArchitecture

@Reducer
public struct HomeFeature {
  @ObservableState
  public struct State: Equatable {
    @CasePathable @dynamicMemberLookup
    public enum FetchStatus: Equatable {
      case pending
      case success(HomeData)
      case failure(reason: String)
    }

    public var fetchStatus: FetchStatus = .pending
    public var path = StackState<Path.State>()
  }

  public enum Action {
    case fetchHomeData
    case homeDataResponse(Result<HomeData, any Error>)
    case path(StackActionOf<Path>)
  }

  @Reducer
  public enum Path {
    case recentlyAdded
    case manga
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchHomeData:
        return .none
      case let .homeDataResponse(.success(data)):
        state.fetchStatus = .success(data)
        return .none
      case let .homeDataResponse(.failure(error)):
        state.fetchStatus = .failure(reason: error.localizedDescription)
        return .none
      case .path:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
  }
}
