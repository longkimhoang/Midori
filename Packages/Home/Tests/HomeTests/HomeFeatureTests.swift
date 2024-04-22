//
//  HomeFeatureTests.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import ComposableArchitecture
import Home
import XCTest

final class HomeFeatureTests: XCTestCase {
  @MainActor
  func testFetchData() async {
    let store = TestStore(initialState: HomeFeature.State()) {
      HomeFeature()
    }

    await store.send(\.fetchHomeData)
  }
}
