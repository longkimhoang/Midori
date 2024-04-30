//
//  MangaListView.swift
//
//
//  Created by Long Kim on 29/4/24.
//

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
        ToolbarItem(placement: .topBarTrailing) {
          Picker(selection: $store.layout.sending(\.selectLayout)) {
            Label(layout: .list)
              .tag(MangaListFeature.Layout.list)

            Label(layout: .grid)
              .tag(MangaListFeature.Layout.grid)
          } label: {
            Text("Change layout", bundle: .module)
          }
          .pickerStyle(.segmented)
          .help(Text("Changes the layout of the list view"))
        }
      }
  }
}

private extension Label where Title == Text, Icon == Image {
  init(layout: MangaListFeature.Layout) {
    switch layout {
    case .list:
      self = Label {
        Text("List layout", bundle: .module)
      } icon: {
        Image(systemName: "list.bullet")
      }
    case .grid:
      self = Label {
        Text("Grid layout", bundle: .module)
      } icon: {
        Image(systemName: "square.grid.2x2")
      }
    }
  }
}
