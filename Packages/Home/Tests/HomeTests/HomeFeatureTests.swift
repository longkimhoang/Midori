//
//  HomeFeatureTests.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import ComposableArchitecture
import XCTest

@testable import Home

final class HomeFeatureTests: XCTestCase {
  @MainActor
  func testFetchData() async {
    let uuid = UUIDGenerator.incrementing
    let popularMangas: IdentifiedArrayOf<Manga> = [
      Manga(id: uuid(), name: "Popular Manga 1", description: "Popular Manga 1"),
      Manga(id: uuid(), name: "Popular Manga 2", description: "Popular Manga 2"),
    ]
    let recentlyAddedMangas: IdentifiedArrayOf<Manga> = [
      Manga(id: uuid(), name: "Recent Manga 1", description: "Recent Manga 1"),
      Manga(id: uuid(), name: "Recent Manga 2", description: "Recent Manga 2"),
    ]
    let store = TestStore(initialState: HomeFeature.State()) {
      HomeFeature()
    } withDependencies: {
      $0.homeData.retrievePopularMangas = { popularMangas }
      $0.homeData.retrieveRecentlyAddedMangas = { recentlyAddedMangas }
    }

    await store.send(\.fetchHomeData)

    await store.receive(\.homeDataResponse.success) {
      $0.fetchStatus = .success(
        HomeData(
          popularMangas: popularMangas,
          recentlyAddedMangas: recentlyAddedMangas
        )
      )
    }
  }

  @MainActor
  func testFetchDataFailure() async {
    struct MockError: LocalizedError {
      let errorDescription: String?
    }
    let store = TestStore(initialState: HomeFeature.State()) {
      HomeFeature()
    } withDependencies: {
      $0.homeData.retrievePopularMangas = {
        throw MockError(errorDescription: "Mock")
      }
      $0.homeData.retrieveRecentlyAddedMangas = { [] }
    }

    await store.send(\.fetchHomeData)

    await store.receive(\.homeDataResponse.failure) {
      $0.fetchStatus = .failure(reason: "Mock")
    }
  }
}
