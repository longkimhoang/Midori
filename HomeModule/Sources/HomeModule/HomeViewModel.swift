//
//  HomeViewModel.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import Dependencies
import Foundation
import SwiftUI

@Observable
final class HomeViewModel {

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

  @ObservationIgnored
  @Dependency(\.popularMangas) var popularMangas
  @ObservationIgnored
  @Dependency(\.latestChapters) var latestChapters
  @ObservationIgnored
  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

  var fetchStatus: FetchStatus = .loading

  @discardableResult
  func fetchHomeData() -> Task<Void, Never> {
    Task {
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
