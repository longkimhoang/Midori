//
//  MangaDetailCollectionView+Delegate.swift
//
//
//  Created by Long Kim on 15/5/24.
//

import UIKit

extension MangaDetailCollectionView.Coordinator: UICollectionViewDelegate {
  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let chapterID = dataSource.itemIdentifier(for: indexPath)?.chapter else {
      return
    }

    store.send(.selectChapter(chapterID))
  }
}
