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

  func collectionView(
    _: UICollectionView,
    contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
    point _: CGPoint
  ) -> UIContextMenuConfiguration? {
    guard indexPaths.count == 1,
          let indexPath = indexPaths.first,
          let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
    else {
      return nil
    }

    switch itemIdentifier {
    case let .popular(mangaID), let .recentlyAdded(mangaID):
      return UIContextMenuConfiguration(
        identifier: mangaID as NSUUID,
        actionProvider: { _ in
          let openAction = UIAction(title: String(localized: "Open")) { _ in
            self.store.send(.mangaTapped(mangaID))
          }

          let openWindowAction = UIAction(
            title: String(localized: "Open in a new window"),
            image: UIImage(systemName: "macwindow.badge.plus")
          ) { _ in
            self.openWindow(id: "Midori.MangaDetail", value: mangaID)
          }

          var openMangaMenuElements: [UIMenuElement] = [openAction]
          if self.supportsMultipleWindows {
            openMangaMenuElements.append(openWindowAction)
          }

          let openMangaMenu = UIMenu(options: .displayInline, children: openMangaMenuElements)

          return UIMenu(children: [
            openMangaMenu,
          ])
        }
      )
    case let .latestUpdates(chapterID):
      guard let chapter = store.withState(\.fetchStatus.success?.latestChapters[id: chapterID])
      else {
        return nil
      }

      return UIContextMenuConfiguration(
        identifier: chapterID as NSUUID,
        actionProvider: { _ in
          let viewMangaAction = UIAction(
            title: String(localized: "View manga"),
            image: UIImage(systemName: "book")
          ) { _ in
            self.store.send(.mangaTapped(chapter.mangaID))
          }

          return UIMenu(children: [
            viewMangaAction,
          ])
        }
      )
    }
  }
}
