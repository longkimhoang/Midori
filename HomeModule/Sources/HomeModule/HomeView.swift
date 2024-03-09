//
//  HomeView.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import ComposableArchitecture
import Dependencies
import Foundation
import SwiftUI

enum FetchResult<Success> {
  case loading
  case success(Success)
  case failure(Error)
}

public struct HomeView: View {
  public let store: StoreOf<HomeFeature>

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      HomeCollectionView(data: store.data)
      #if os(iOS)
        .ignoresSafeArea()
      #endif
        .navigationTitle("Home")
        .refreshable {
          await store.send(.fetchHomeData).finish()
        }
        .overlay {
          switch store.state {
          case .loading:
            ContentUnavailableView {
              ProgressView()
                .controlSize(.large)
            } description: {
              Text("Loading...")
            }
          case let .failure(error):
            Text(error.localizedDescription)
          default:
            EmptyView()
          }
        }
    }
    .task {
      store.send(.fetchHomeData)
    }
  }
}
