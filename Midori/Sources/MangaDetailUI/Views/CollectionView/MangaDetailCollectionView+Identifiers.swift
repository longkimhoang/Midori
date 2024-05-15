//
//  MangaDetailCollectionView+Identifiers.swift
//
//
//  Created by Long Kim on 2/5/24.
//

import CasePaths
import Foundation

enum SectionIdentifier {
  case chapters
}

@CasePathable @dynamicMemberLookup
enum ItemIdentifier: Hashable {
  case volume(String?)
  case chapter(UUID)
}

enum SupplementaryItemKind {
  static let mangaInfoHeader = "MangaDetail.InfoHeader"
}
