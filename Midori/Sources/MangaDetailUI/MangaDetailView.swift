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
      .navigationTitle(title ?? "")
      .navigationBarTitleDisplayMode(.inline)
      .task {
        await store.send(.fetchMangaFeed).finish()
      }
  }

  private var title: String? {
    guard let manga = store.fetchStatus.success?.manga else {
      return nil
    }

    return manga.title.localized(for: locale)
  }
}
