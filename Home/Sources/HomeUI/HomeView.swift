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
  @State private var isRefreshing: Bool = false
  @StateObject private var model = HomeDataModel()
  @StateObject private var navigationStore = HomeNavigationStore()
  @SceneStorage("HomeView.navigation") private var storedNavigationData: Data?
  @SceneStorage("HomeView.data") private var storedHomeData: Data?

  public init() {}

  public var body: some View {
    NavigationStack(path: $navigationStore.path) {
      HomeCollectionView(fetchStatus: model.fetchStatus, path: $navigationStore.path)
        .ignoresSafeArea()
        .navigationTitle(Text("Home", bundle: .module))
        .toolbar {
          #if os(macOS)
          ToolbarItem {
            RefreshButton(isRefreshing: isRefreshing)
          }
          #endif
        }
        .overlay {
          #if os(macOS)
          switch model.fetchStatus {
          case .loading:
            ContentUnavailableView.loading
          case let .failure(error):
            ContentUnavailableView {
              Label("Error fetching content", bundle: .module, systemImage: "network.slash")
            } description: {
              Text(error.localizedDescription)
            } actions: {
              RefreshButton()
            }
          default:
            EmptyView()
          }
          #endif
        }
        .navigationDestination(for: HomeNavigationDestination.self) { destination in
          switch destination {
          case .recentlyAdded:
            RecentlyAddedDetailView()
          case .latestUpdates:
            LatestUpdatesDetailView()
          default:
            Text("Not implemented")
          }
        }
    }
    .refreshable {
      isRefreshing = true
      defer { isRefreshing = false }
      await model.fetch()
    }
    .task {
      if let storedNavigationData {
        navigationStore.restore(from: storedNavigationData)
      }

      if let storedHomeData {
        try? model.restore(from: storedHomeData)
      }

      await model.fetch()
    }
    .onChange(of: navigationStore.path) {
      storedNavigationData = navigationStore.serialziedData
    }
    .onReceive(model.objectWillChange) {
      storedHomeData = model.serializedData
    }
  }
}

#if os(macOS)
private struct RefreshButton: View {
  var isRefreshing: Bool = false
  @Environment(\.refresh) private var refresh

  var body: some View {
    Button {
      Task {
        await refresh?()
      }
    } label: {
      if isRefreshing {
        ProgressView()
          .controlSize(.small)
      } else {
        Label("Refresh", bundle: .module, systemImage: "arrow.clockwise")
      }
    }
    .keyboardShortcut("r", modifiers: .command)
  }
}
#endif
