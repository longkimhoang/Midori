//
//  HomeView.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import CommonUI
import HomeCore
import SwiftUI

public struct HomeView: View {
  @StateObject private var dataStore = HomeDataStore()
  @StateObject private var navigationStore = HomeNavigationStore()
  @SceneStorage("HomeView.navigation") private var storedNavigationData: Data?
  @SceneStorage("HomeView.data") private var storedHomeData: Data?

  public init() {}

  public var body: some View {
    NavigationStack(path: $navigationStore.path) {
      HomeCollectionView(fetchStatus: dataStore.fetchStatus, path: $navigationStore.path)
        .ignoresSafeArea()
        .navigationTitle(Text("Home", bundle: .module))
        .toolbar {
          #if os(macOS)
          ToolbarItem {
            RefreshButton()
          }
          #endif
        }
        .overlay {
          #if os(macOS)
          switch dataStore.fetchStatus {
          case .loading:
            ContentUnavailableView.loading
          default:
            EmptyView()
          }
          #endif
        }
        .navigationDestination(for: HomeNavigationDestination.self) { destination in
          switch destination {
          case .recentlyAdded:
            RecentlyAddedDetailView()
          default:
            Text("Not implemented")
          }
        }
    }
    .refreshable {
      await dataStore.fetch()
    }
    .task {
      if let storedNavigationData {
        navigationStore.restore(from: storedNavigationData)
      }

      if let storedHomeData {
        try? dataStore.restore(from: storedHomeData)
      } else {
        await dataStore.fetch()
      }
    }
    .onChange(of: navigationStore.path) {
      storedNavigationData = navigationStore.serialziedData
    }
    .onReceive(dataStore.objectWillChange) {
      storedHomeData = dataStore.serializedData
    }
  }
}

#if os(macOS)
private struct RefreshButton: View {
  @Environment(\.refresh) private var refresh

  var body: some View {
    Button {
      Task {
        await refresh?()
      }
    } label: {
      Label("Refresh", bundle: .module, systemImage: "arrow.clockwise")
    }
    .keyboardShortcut("r", modifiers: .command)
  }
}
#endif
