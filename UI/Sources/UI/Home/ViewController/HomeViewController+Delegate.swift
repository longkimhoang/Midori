//
//  HomeViewController+Delegate.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import UIKit

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case let .popularManga(mangaID):
            store.send(.mangaSelected(mangaID))
        case .latestChapter:
            break
        case let .recentlyAddedManga(mangaID):
            store.send(.mangaSelected(mangaID))
        }
    }
}
