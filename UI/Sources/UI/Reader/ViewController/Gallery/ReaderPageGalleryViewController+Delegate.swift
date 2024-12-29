//
//  ReaderPageGalleryViewController+Delegate.swift
//  UI
//
//  Created by Long Kim on 24/12/24.
//

import UIKit

extension ReaderPageGalleryViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        selectedPageID = itemIdentifier
        dismiss(animated: true)
    }
}
