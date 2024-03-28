//
//  HomeFeature.swift
//
//
//  Created by Long Kim on 28/3/24.
//

import ComposableArchitecture

@Reducer
public struct HomeFeature {
  @ObservableState
  public struct State {
    public var fetchStatus: HomeDataFetchStatus = .loading
    @Presents public var recentlyAddedDetail: RecentlyAddedDetailFeature.State?

    public init() {}
  }

  public enum Action: ViewAction {
    case dataResponse(HomeData)
    case view(View)
    case recentlyAddedDetail(PresentationAction<RecentlyAddedDetailFeature.Action>)

    public enum View {
      case fetchData
      case navigateToRecentlyAddedDetail
    }
  }

  @Dependency(\.popularMangas) var popularMangas
  @Dependency(\.latestChapters) var latestChapters
  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.fetchData):
        return .run { send in
          async let popularMangas = try await popularMangas.fetch()
          async let latestChapters = try await latestChapters.fetch()
          async let recentlyAddedMangas = try await recentlyAddedMangas.fetch()

          let data = try await HomeData(
            popularMangas: IdentifiedArray(uniqueElements: popularMangas),
            latestChapters: IdentifiedArray(uniqueElements: latestChapters),
            recentlyAddedMangas: IdentifiedArray(uniqueElements: recentlyAddedMangas)
          )

          await send(.dataResponse(data))
        }
      case .view(.navigateToRecentlyAddedDetail):
        state.recentlyAddedDetail = RecentlyAddedDetailFeature.State()
        return .none
      case let .dataResponse(data):
        state.fetchStatus = .success(data)
        return .none
      case .recentlyAddedDetail:
        return .none
      }
    }
    .ifLet(\.$recentlyAddedDetail, action: \.recentlyAddedDetail) {
      RecentlyAddedDetailFeature()
    }
  }
}
