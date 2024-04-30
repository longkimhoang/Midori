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
  public let store: StoreOf<MangaDetailFeature>

  public init(store: StoreOf<MangaDetailFeature>) {
    self.store = store
  }

  public var body: some View {
    EmptyView()
  }
}
