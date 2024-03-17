//
//  MangaListLayout.swift
//
//
//  Created by Long Kim on 17/3/24.
//

import CommonUI
import SwiftUI

public enum MangaListLayout: Int, CaseIterable {
  case list
  case grid
}

extension Label where Title == Text, Icon == Image {
  init(_ layout: MangaListLayout) {
    switch layout {
    case .list:
      self = Label("List", bundle: .module, systemImage: "list.bullet")
    case .grid:
      self = Label("Grid", bundle: .module, systemImage: "square.grid.2x2")
    }
  }
}
