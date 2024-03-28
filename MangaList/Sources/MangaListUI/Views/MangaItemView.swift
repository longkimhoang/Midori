//
//  MangaItemView.swift
//
//
//  Created by Long Kim on 17/3/24.
//

import Database
import MangaListCore
import SwiftUI

struct MangaItemView: View {
  let manga: Manga
  let image: Image?
  let layout: MangaListLayout

  var body: some View {
    switch layout {
    case .list:
      MangaListItemView(manga: manga, coverImage: image)
    case .grid:
      MangaGridItemView(manga: manga, coverImage: image)
    }
  }
}
