//
//  HomeFeature.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import ComposableArchitecture
import Models
import Networking
import Foundation

@Reducer
public struct HomeFeature: Sendable {
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

    public init() {}
  }

  public enum Action: Sendable {
    case fetchHomeData
    case homeDataResponse(Result<HomeData.FetchDescriptor, any Error>)
    case path(StackActionOf<Path>)
  }

  @Reducer(state: .equatable, .sendable, action: .sendable)
  public enum Path {
    case recentlyAdded
    case manga
  }

  @Dependency(\.homeData) var homeData
  @Dependency(\.mangaRepository) var mangaRepository

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchHomeData:
        return .run { send in
          async let popularMangas = try await homeData.retrievePopularMangas()
          async let recentlyAddedMangas = try await homeData.retrieveRecentlyAddedMangas()

          let descriptor = try await HomeData.FetchDescriptor(
            popularMangaIDs: popularMangas.map(\.id),
            recentlyAddedMangaIDs: recentlyAddedMangas.map(\.id)
          )
          await send(.homeDataResponse(.success(descriptor)))
        } catch: { error, send in
          await send(.homeDataResponse(.failure(error)))
        }
      case let .homeDataResponse(.success(descriptor)):
        do {
          let data = try MainActor.assumeIsolated {
            try HomeData(
              popularMangas: fetchMangas(ids: descriptor.popularMangaIDs),
              recentlyAddedMangas: fetchMangas(ids: descriptor.recentlyAddedMangaIDs)
            )
          }
          state.fetchStatus = .success(data)
        } catch {
          state.fetchStatus = .failure(reason: error.localizedDescription)
        }
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

  @MainActor
  private func fetchMangas(ids: [UUID]) throws -> IdentifiedArrayOf<Models.Manga> {
    try IdentifiedArray(
      uniqueElements: mangaRepository.fetchMangas(mangaIDs: ids)
    )
  }
}
