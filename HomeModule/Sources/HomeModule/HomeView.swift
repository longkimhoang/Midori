//
//  HomeView.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import ComposableArchitecture
import SwiftUI

@ViewAction(for: HomeFeature.self)
public struct HomeView: View {
  public let store: StoreOf<HomeFeature>

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      HomeCollectionView(store: store)
      #if os(iOS)
        .ignoresSafeArea()
      #endif
        .navigationTitle("Home")
        .refreshable {
          await send(.fetchPopularMangas).finish()
        }
    }
    .task {
      await send(.fetchPopularMangas).finish()
    }
  }
}
