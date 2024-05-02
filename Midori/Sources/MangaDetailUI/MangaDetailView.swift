//
//  MangaDetailView.swift
//
//
//  Created by Long Kim on 30/4/24.
//

import ComposableArchitecture
import MangaDetailCore
import SwiftUI

public struct MangaDetailView: View {
  @Environment(\.locale) private var locale

  public let store: StoreOf<MangaDetailFeature>

  public init(store: StoreOf<MangaDetailFeature>) {
    self.store = store
  }

  public var body: some View {
    MangaDetailCollectionView(store: store)
      .navigationTitle(store.fetchStatus.success?.title.localized(for: locale) ?? "")
      .navigationBarTitleDisplayMode(.inline)
      .task {
        await store.send(.fetchMangaFeed).finish()
      }
  }
}
