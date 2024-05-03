//
//  HomeCollectionView+Delegate.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import UIKit

extension HomeCollectionView.Coordinator: UICollectionViewDelegate {
  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
      return
    }

    switch itemIdentifier {
    case let .popular(mangaID), let .recentlyAdded(mangaID):
      store.send(.mangaTapped(mangaID))
    default:
      break
    }
  }
}
