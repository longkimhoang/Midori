//
//  HomeView.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import Dependencies
import Foundation
import HomeDomain
import SwiftUI

enum FetchResult<Success> {
  case loading
  case success(Success)
  case failure(Error)
}

public struct HomeView: View {
  @Dependency(HomeDataProvider.self) var homeDataProvider
  @State private var result: FetchResult<HomeData> = .loading

  public init() {}

  public var body: some View {
    NavigationStack {
      HomeCollectionView(data: result.data)
      #if os(iOS)
        .ignoresSafeArea()
      #endif
        .overlay {
          switch result {
          case .loading:
            ContentUnavailableView {
              ProgressView()
                .controlSize(.large)
            } description: {
              Text("Loading...")
            }
          case .success:
            EmptyView()
          case let .failure(error):
            Text(error.localizedDescription)
          }
        }
        .navigationTitle("Home")
        .refreshable {
          await fetchHomeData()
        }
    }
    .task {
      await fetchHomeData()
    }
  }

  private func fetchHomeData() async {
    do {
      let homeData = try await homeDataProvider.retrieveHomeData()
      result = .success(homeData)
    } catch {
      dump(error)
      result = .failure(error)
    }
  }
}

extension FetchResult<HomeData> {
  fileprivate var data: HomeData? {
    switch self {
    case let .success(data): data
    default: nil
    }
  }
}
