//
//  MangaListCollectionView+Delegate.swift
//
//
//  Created by Long Kim on 30/4/24.
//

import UIKit

extension MangaListCollectionView.Coordinator: UICollectionViewDelegate {
  func collectionView(
    _: UICollectionView,
    willDisplay _: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    let isAtEnd = store.withState { indexPath.item + 1 == $0.mangas.endIndex }
    if isAtEnd {
      store.send(.delegate(.listEndReached), animation: .default)
    }
  }

  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let mangaID = dataSource.itemIdentifier(for: indexPath) else {
      return
    }

    store.send(.delegate(.mangaSelected(mangaID)))
  }
}
