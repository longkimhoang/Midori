//
//  MangaListView.swift
//
//
//  Created by Long Kim on 14/3/24.
//

import CommonUI
import ComposableArchitecture
import MangaListCore
import SwiftUI

public struct MangaListView: View {
  @Bindable public var store: StoreOf<MangaListFeature>

  public init(store: StoreOf<MangaListFeature>) {
    self.store = store
  }

  public var body: some View {
    MangaListCollectionView(store: store)
      .ignoresSafeArea()
      .toolbar {
        ToolbarItem {
          Picker(selection: $store.layout.sending(\.view.layoutChanged)) {
            ForEach(MangaListFeature.State.Layout.allCases, id: \.self) {
              $0.label
            }
          } label: {
            Text("Layout", bundle: .module)
          }
          .pickerStyle(.segmented)
          .help(Text("Changes the layout of the mangas list.", bundle: .module))
        }
      }
  }
}

extension MangaListFeature.State.Layout {
  fileprivate var label: some View {
    switch self {
    case .list:
      Label("Toggle list view", bundle: .module, systemImage: "list.bullet")
    case .grid:
      Label("Toggle grid view", bundle: .module, systemImage: "square.grid.2x2")
    }
  }
}
