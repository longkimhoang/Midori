//
//  HomeView.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import ComposableArchitecture
import ConcurrencyExtras
import Database
import Dependencies
import Foundation
import SwiftUI
import IdentifiedCollections

@Reducer
struct CounterFeature {
  @ObservableState
  struct State {
    var fetchStatus: HomeViewModel.FetchStatus = .loading
  }

  enum Action {
    case fetchPopularMangas
    case homeDataResponse(HomeData)
    case homeDataFailure(Error)
  }

  @Dependency(\.popularMangas) var popularMangas
  @Dependency(\.latestChapters) var latestChapters
  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchPopularMangas:
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
        state.fetchStatus = .success(data)
        return .none
      case let .homeDataFailure(error):
        state.fetchStatus = .failure(error)
        return .none
      }
    }
  }
}

public struct HomeView: View {
  @State private var model = HomeViewModel()
  let store: StoreOf<CounterFeature>

  init(store: StoreOf<CounterFeature>) {
    self.store = store
  }

  public init() {
    self.init(store: Store(initialState: CounterFeature.State()) {
      CounterFeature()
    })
  }

  public var body: some View {
    NavigationStack {
      HomeCollectionView(store: store)
      #if os(iOS)
        .ignoresSafeArea()
      #endif
        .navigationTitle("Home")
        .refreshable {
          await store.send(.fetchPopularMangas).finish()
        }
    }
    .task {
      await store.send(.fetchPopularMangas).finish()
    }
  }
}
