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
  public let store: StoreOf<HomeFeature>

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      HomeCollectionView(store: store)
        .navigationTitle("Hehe")
        .ignoresSafeArea()
        .task {
          await store.send(.fetchHomeData).finish()
        }
    }
  }
}
