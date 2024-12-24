//
//  HomeViewController+Delegate.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import SwiftUI
import UIKit

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case let .popularManga(mangaID):
            viewModel.mangaSelected(id: mangaID)
        case let .latestChapter(chapterID):
            viewModel.latestChapterSelected(id: chapterID)
        case let .recentlyAddedManga(mangaID):
            viewModel.mangaSelected(id: mangaID)
        }
    }

    func collectionView(
        _: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point _: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first, let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        switch itemIdentifier {
        case let .latestChapter(chapterID):
            guard let chapter = viewModel.data.latestChapters[id: chapterID],
                  let cell = collectionView.cellForItem(at: indexPath) as? LatestChapterCell
            else {
                return nil
            }

            let readChapterAction = UIAction(
                title: String(localized: "Read chapter", bundle: .main),
                image: UIImage(systemName: "book"),
                handler: { [unowned self] _ in
                    viewModel.latestChapterSelected(id: chapterID)
                }
            )

            let viewMangaAction = UIAction(
                title: String(localized: "View manga", bundle: .main),
                image: UIImage(systemName: "books.vertical"),
                handler: { [unowned self] _ in
                    viewModel.mangaSelected(id: chapter.mangaInfo.id)
                }
            )

            return UIContextMenuConfiguration(
                previewProvider: {
                    let content = cell.coordinator.previewContent
                    let hostingController = UIHostingController(rootView: content)
                    hostingController.sizingOptions = [.preferredContentSize]
                    let size = hostingController.view.intrinsicContentSize
                    hostingController.preferredContentSize = size
                    return hostingController
                },
                actionProvider: { _ in
                    let menu = UIMenu(children: [readChapterAction, viewMangaAction])
                    return menu
                }
            )
        case .popularManga, .recentlyAddedManga:
            return nil
        }
    }
}
