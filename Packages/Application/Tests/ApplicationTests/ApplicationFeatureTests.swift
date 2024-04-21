//
//  ApplicationFeatureTests.swift
//
//
//  Created by Long Kim on 21/4/24.
//

import ComposableArchitecture
import XCTest

@testable import Application

final class ApplicationFeatureTests: XCTestCase {
  @MainActor
  func testTabSelection() async {
    let store = TestStore(initialState: ApplicationFeature.State()) {
      ApplicationFeature()
    }

    await store.send(.selectTab(.search)) {
      $0.selectedTab = .search
    }

    await store.send(.selectTab(.home)) {
      $0.selectedTab = .home
    }
  }
}
