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
        .ignoresSafeArea()
        .navigationTitle("Home")
        .toolbar {
          ToolbarItem {
            refreshButton
          }
        }
    }
    .task {
      await send(.fetchPopularMangas).finish()
    }
  }

  @ViewBuilder
  private var refreshButton: some View {
    Button {
      send(.fetchPopularMangas)
    } label: {
      Label {
        Text("Refresh", bundle: .module)
      } icon: {
        Image(systemName: "arrow.triangle.2.circlepath")
      }
    }
  }
}
