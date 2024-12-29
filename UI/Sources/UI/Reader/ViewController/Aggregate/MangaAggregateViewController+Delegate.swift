//
//  MangaAggregateViewController+Delegate.swift
//  UI
//
//  Created by Long Kim on 16/12/24.
//

import UIKit

extension MangaAggregateViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) {
        guard let chapterID = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        viewModel.selectedChapter = chapterID
    }
}
