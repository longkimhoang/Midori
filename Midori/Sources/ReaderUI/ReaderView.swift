//
//  ReaderView.swift
//
//
//  Created by Long Kim on 14/5/24.
//

import ComposableArchitecture
import ReaderCore
import SwiftUI

public struct ReaderView: View {
  public let store: StoreOf<ReaderFeature>

  public init(store: StoreOf<ReaderFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      PageView(store: store)
    }
    .task {
      await store.send(.fetchPageURLs).finish()
    }
  }
}
