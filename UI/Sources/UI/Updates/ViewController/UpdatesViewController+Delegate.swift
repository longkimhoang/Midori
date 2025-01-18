//
//  UpdatesViewController+Delegate.swift
//  UI
//
//  Created by Long Kim on 18/1/25.
//

import Dependencies
import MidoriViewModels
import UIKit

extension UpdatesViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case let .header(mangaID):
            let mangaDetailModel = withDependencies(from: viewModel) {
                MangaDetailViewModel(mangaID: mangaID)
            }
            let mangaDetailViewController = MangaDetailViewController(model: mangaDetailModel)
            show(mangaDetailViewController, sender: self)
        case let .item(chapterID):
            collectionView.deselectItem(at: indexPath, animated: true)
            let readerModel = withDependencies(from: viewModel) {
                ReaderViewModel(chapterID: chapterID)
            }
            let readerViewController = ReaderViewController(model: readerModel)
            let viewController = UINavigationController(rootViewController: readerViewController)
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }
}
