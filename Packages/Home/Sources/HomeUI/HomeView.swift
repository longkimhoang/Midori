//
//  HomeView.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import ComposableArchitecture
import Home
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
          await store.send(.fetchHomeData).finish()
        }
    } destination: { store in
      switch store.state {
      case .recentlyAdded:
        if let store = store.scope(state: \.recentlyAdded, action: \.recentlyAdded) {
          Text("Recently added")
        }
      case .manga:
        EmptyView()
      }
    }
  }
}
