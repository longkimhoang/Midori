//
//  HomeView.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import CommonUI
import ComposableArchitecture
import HomeCore
import SwiftUI

@ViewAction(for: HomeFeature.self)
public struct HomeView: View {
  @Bindable public var store: StoreOf<HomeFeature>

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      HomeCollectionView(store: store)
        .ignoresSafeArea()
        .navigationTitle(Text("Home", bundle: .module))
        .toolbar {
          #if os(macOS)
          ToolbarItem {
            refreshButton
          }
          #endif
        }
        .overlay {
          #if os(macOS)
          switch store.fetchStatus {
          case .loading:
            ContentUnavailableView {
              ProgressView()
                .controlSize(.large)
            } description: {
              Text("Loading...", bundle: .module)
            }
          default:
            EmptyView()
          }
          #endif
        }
    } destination: { store in
      switch store.state {
      case .latestUpdatesDetail:
        if let store = store.scope(state: \.latestUpdatesDetail, action: \.latestUpdatesDetail) {
          LatestUpdatesDetailView(store: store)
        }
      case .recentlyAddedDetail:
        if let store = store.scope(state: \.recentlyAddedDetail, action: \.recentlyAddedDetail) {
          RecentlyAddedDetailView(store: store)
        }
      }
    }
    .task {
      if case .loading = store.fetchStatus {
        await send(.fetchPopularMangas).finish()
      }
    }
  }

  @ViewBuilder
  private var refreshButton: some View {
    Button {
      send(.fetchPopularMangas)
    } label: {
      if store.isRefreshing {
        ProgressView()
          .controlSize(.small)
      } else {
        Label("Refresh", bundle: .module, systemImage: "arrow.clockwise")
      }
    }
    .keyboardShortcut("r", modifiers: .command)
  }
}
