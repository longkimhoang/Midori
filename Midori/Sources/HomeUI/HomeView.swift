//
//  HomeView.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Common
import ComposableArchitecture
import HomeCore
import MangaDetailUI
import SwiftUI

public struct HomeView: View {
  @Bindable public var store: StoreOf<HomeFeature>

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      HomeCollectionView(store: store)
        .navigationTitle(Text("Home", bundle: .module))
        .ignoresSafeArea()
        .task {
          guard store.fetchStatus == .pending else { return }
          await store.send(.fetchHomeData).finish()
        }
      #if targetEnvironment(macCatalyst)
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button("Refresh", bundle: .module, systemImage: "arrow.counterclockwise") {
              store.send(.fetchHomeData)
            }
          }
        }
      #endif
    } destination: { store in
      switch store.state {
      case .recentlyAdded:
        if let store = store.scope(state: \.recentlyAdded, action: \.recentlyAdded) {
          RecentlyAddedView(store: store)
        }
      case .manga:
        if let store = store.scope(state: \.manga, action: \.manga) {
          MangaDetailView(store: store)
        }
      }
    }
  }
}
