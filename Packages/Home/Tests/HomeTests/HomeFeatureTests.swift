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
    let store = TestStore(initialState: HomeFeature.State()) {
      HomeFeature()
    } withDependencies: {
      $0.homeData.retrievePopularMangas = { [] }
    }

    await store.send(\.fetchHomeData)

    await store.receive(\.homeDataResponse.success) {
      $0.fetchStatus = .success(
        HomeData(popularMangas: [])
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
    }

    await store.send(\.fetchHomeData)

    await store.receive(\.homeDataResponse.failure) {
      $0.fetchStatus = .failure(reason: "Mock")
    }
  }
}
