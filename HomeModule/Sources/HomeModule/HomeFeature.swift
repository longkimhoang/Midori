//
//  HomeFeature.swift
//
//
//  Created by Long Kim on 08/03/2024.
//

import ComposableArchitecture
import CoreData
import Domain
import Foundation

public struct HomeDataFetchRequest {
  let popularMangaIDs: [NSManagedObjectID]
}

@Reducer
struct HomeFeature {
  @ObservableState
  enum State {
    case loading
    case data(HomeData)
    case failure(Error)
  }

  public enum Action {
    case fetchHomeData
    case homeDataResponse(HomeData)
    case homeDataFailure(Error)
  }

  public init() {}

  @Dependency(\.popularMangas) var popularMangas
  @Dependency(\.latestChapters) var latestChapters
  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchHomeData:
        return .run { send in
          async let popularMangas = try await popularMangas.fetch()
          async let latestChapters = try await latestChapters.fetch()
          async let recentlyAddedMangas = try await recentlyAddedMangas.fetch()

          let data = try await HomeData(
            popularMangas: popularMangas,
            latestChapters: latestChapters,
            recentlyAddedMangas: recentlyAddedMangas
          )

          await MainActor.run {
            print(data.latestChapters.first.map(\.id))
          }

          await send(.homeDataResponse(data))
        } catch: { error, send in
          await send(.homeDataFailure(error))
        }
      case let .homeDataResponse(data):
        state = .data(data)
        return .none
      case let .homeDataFailure(error):
        state = .failure(error)
        return .none
      }
    }
  }
}
