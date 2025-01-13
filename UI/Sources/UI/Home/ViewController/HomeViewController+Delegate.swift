//
//  HomeViewController+Delegate.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import SwiftUI
import UIKit

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) {
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
                  let cell = collectionView.cellForItem(at: indexPath),
                  let configuration = cell.contentConfiguration as? LatestChapterUIConfiguration,
                  let serializedIdentifier = try? JSONEncoder().encode(itemIdentifier)
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
                identifier: String(decoding: serializedIdentifier, as: UTF8.self) as NSString,
                previewProvider: {
                    let content = LatestChapterPreviewView(
                        manga: configuration.manga,
                        chapter: configuration.chapter,
                        group: configuration.group,
                        coverImage: configuration.coverImage.map(Image.init)
                    )
                    let hostingController = UIHostingController(rootView: content)
                    let contentSize = hostingController.sizeThatFits(
                        in: CGSize(width: 300, height: UIView.layoutFittingExpandedSize.height)
                    )
                    hostingController.preferredContentSize = contentSize
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

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration _: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        switch itemIdentifier {
        case .latestChapter:
            guard let cell = collectionView.cellForItem(at: indexPath) else {
                return nil
            }

            let parameters = UIPreviewParameters()
            parameters.visiblePath = UIBezierPath(
                roundedRect: cell.bounds.inset(by: .init(top: 0, left: -8, bottom: 0, right: 0)),
                cornerRadius: 8
            )

            return UITargetedPreview(view: cell, parameters: parameters)
        case .popularManga, .recentlyAddedManga:
            return nil
        }
    }

    func collectionView(
        _: UICollectionView,
        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: any UIContextMenuInteractionCommitAnimating
    ) {
        guard let serializedItemIdentifier = configuration.identifier as? String,
              let itemIdentifier = try? JSONDecoder().decode(
                  ItemIdentifier.self,
                  from: Data(serializedItemIdentifier.utf8)
              )
        else {
            return
        }

        switch itemIdentifier {
        case let .latestChapter(chapterID):
            guard let chapter = viewModel.data.latestChapters[id: chapterID] else {
                return
            }

            animator.addAnimations {
                self.navigateToMangaDetail(mangaID: chapter.mangaInfo.id)
            }
        case .popularManga, .recentlyAddedManga:
            break
        }
    }
}
