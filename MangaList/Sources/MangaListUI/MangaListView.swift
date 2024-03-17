//
//  MangaListView.swift
//
//
//  Created by Long Kim on 14/3/24.
//

import CommonUI
import Database
import IdentifiedCollections
import MangaListCore
import SwiftUI

public struct MangaListView: View {
  public var mangas: IdentifiedArrayOf<Manga>
  @State private var layout: MangaListLayout

  public init(
    mangas: IdentifiedArrayOf<Manga>,
    layout: MangaListLayout = .list
  ) {
    self.mangas = mangas
    _layout = State(initialValue: layout)
  }

  public var body: some View {
    MangaListCollectionView(mangas: mangas, layout: layout)
      .ignoresSafeArea()
      .toolbar {
        ToolbarItem {
          Picker(selection: $layout) {
            ForEach(MangaListLayout.allCases, id: \.self) { layout in
              Label(layout)
            }
          } label: {
            Text("Layout", bundle: .module)
          }
          .help(Text("Changes the layout of the mangas list.", bundle: .module))
          .pickerStyle(.segmented)
        }
      }
  }
}
