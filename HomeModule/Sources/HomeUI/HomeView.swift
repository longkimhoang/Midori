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
      Group {
        switch result {
        case .loading:
          ContentUnavailableView {
            ProgressView()
              .controlSize(.large)
          } description: {
            Text("Loading...")
          }
        case let .success(data):
          HomeCollectionView(data: data)
          #if os(iOS)
            .ignoresSafeArea()
          #endif
        case let .failure(error):
          Text(error.localizedDescription)
        }
      }
      .navigationTitle("Home")
    }
    .task {
      do {
        let homeData = try await homeDataProvider.retrieveHomeData()
        result = .success(homeData)
      } catch {
        result = .failure(error)
      }
    }
  }
}
