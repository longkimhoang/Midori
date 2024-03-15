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
          #if os(iOS)
          Menu {
            Section {
              layoutPicker
            } header: {
              Text("Layout", bundle: .module)
            }
          } label: {
            Label("Options", bundle: .module, systemImage: "ellipsis.circle")
          }
          .pickerStyle(.inline)
          #else
          layoutPicker
            .pickerStyle(.segmented)
            .help(Text("Changes the layout of the mangas list.", bundle: .module))
          #endif
        }
      }
  }

  @ViewBuilder
  private var layoutPicker: some View {
    Picker(selection: $store.layout.sending(\.view.layoutChanged)) {
      ForEach(MangaListFeature.State.Layout.allCases, id: \.self) {
        $0.label
      }
    } label: {
      Text("Layout", bundle: .module)
    }
  }
}

extension MangaListFeature.State.Layout {
  fileprivate var label: some View {
    switch self {
    case .list:
      Label("List", bundle: .module, systemImage: "list.bullet")
    case .grid:
      Label("Grid", bundle: .module, systemImage: "square.grid.2x2")
    }
  }
}
