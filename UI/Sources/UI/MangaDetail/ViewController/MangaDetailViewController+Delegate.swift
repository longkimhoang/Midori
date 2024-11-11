//
//  MangaDetailViewController+Delegate.swift
//  UI
//
//  Created by Long Kim on 12/11/24.
//

import UIKit

extension MangaDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case let .chapter(_, chapterID):
            collectionView.deselectItem(at: indexPath, animated: true)
            viewModel.chapterSelected(id: chapterID)
        case .mangaDetailHeader:
            break
        case .volume:
            break
        }
    }
}
