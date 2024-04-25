//
//  HomeFeature.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import ComposableArchitecture
import Foundation
import Models
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
    case path(StackActionOf<Path>)
  }

  @Reducer(state: .equatable, .sendable, action: .sendable)
  public enum Path {
    case recentlyAdded
    case manga
  }

  @Dependency(\.homeData) var homeData

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchHomeData:
        return .run { send in
          async let popularMangas = try await homeData.retrievePopularMangas()
          async let recentlyAddedMangas = try await homeData.retrieveRecentlyAddedMangas()

          let data = try await HomeData(
            popularMangas: popularMangas,
            recentlyAddedMangas: recentlyAddedMangas
          )
          await send(.homeDataResponse(.success(data)))
        } catch: { error, send in
          await send(.homeDataResponse(.failure(error)))
        }
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
