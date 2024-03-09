//
//  HomeViewModel.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import Dependencies
import Foundation
import SwiftUI

final class HomeViewModel: ObservableObject {

  enum FetchStatus {
    case loading
    case success(HomeData)
    case failure(Error)

    var data: HomeData? {
      switch self {
      case let .success(data): data
      default: nil
      }
    }
  }

  @Dependency(\.popularMangas) var popularMangas
  @Dependency(\.latestChapters) var latestChapters
  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

  @Published var fetchStatus: FetchStatus = .loading

  @discardableResult
  func fetchHomeData() -> Task<Void, Never> {
    Task { @MainActor in
      do {
        async let popularMangas = try await popularMangas.fetch()
        async let latestChapters = try await latestChapters.fetch()
        async let recentlyAddedMangas = try await recentlyAddedMangas.fetch()

        let data = try await HomeData(
          popularMangas: popularMangas,
          latestChapters: latestChapters,
          recentlyAddedMangas: recentlyAddedMangas
        )

        withAnimation {
          fetchStatus = .success(data)
        }
      } catch {
        withAnimation {
          fetchStatus = .failure(error)
        }
      }
    }
  }
}
