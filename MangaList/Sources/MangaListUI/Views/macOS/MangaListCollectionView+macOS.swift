//
//  MangaListCollectionView+macOS.swift
//
//
//  Created by Long Kim on 14/3/24.
//

#if os(macOS)
import AdvancedCollectionTableView
import ComposableArchitecture
import Database
import FZUIKit
import MangaListCore
import SwiftData
import SwiftUI

struct MangaListCollectionView: NSViewRepresentable {
  let store: StoreOf<MangaListFeature>

  func makeNSView(context: Context) -> NSScrollView {
    let collectionView = NSCollectionView()
    collectionView.collectionViewLayout = .mangaList()
    collectionView.delegate = context.coordinator
    context.coordinator.setupDataSource(for: collectionView)

    let scrollView = NSScrollView()
    scrollView.documentView = collectionView
    return scrollView
  }

  func updateNSView(_: NSScrollView, context _: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(store: store)
  }

  @ViewAction(for: MangaListFeature.self)
  final class Coordinator: NSObject {
    let store: StoreOf<MangaListFeature>
    private var dataSource: NSCollectionViewDiffableDataSource<SectionIdentifier, Manga.ID>!

    init(store: StoreOf<MangaListFeature>) {
      self.store = store
    }

    func setupDataSource(for collectionView: NSCollectionView) {
      let mangaListCellRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, Manga> {
        item, _, manga in

        item.contentConfiguration = NSHostingConfiguration {
          MangaListItemView(manga: manga, coverImage: nil)
        }
        .margins(.all, 0)
      }
      dataSource =
        NSCollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier in

          guard let self, let manga = store.mangas[id: itemIdentifier] else { return nil }
          return collectionView.makeItem(
            using: mangaListCellRegistration,
            for: indexPath,
            element: manga
          )
        }

      observe { [weak self] in
        guard let self else { return }

        updateDataSource(with: store.mangas)
      }
    }

    private func updateDataSource(with mangas: IdentifiedArrayOf<Manga>) {
      var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, Manga.ID>()
      snapshot.appendSections([.main])
      snapshot.appendItems(mangas.map(\.id))
      dataSource.apply(snapshot, animatingDifferences: true)
    }
  }
}

extension MangaListCollectionView.Coordinator: NSCollectionViewDelegate {
  func collectionView(
    _: NSCollectionView,
    willDisplay _: NSCollectionViewItem,
    forRepresentedObjectAt indexPath: IndexPath
  ) {
    if indexPath.item == store.mangas.count - 1 {
      send(.delegate(.scrollEndReached))
    }
  }
}

private enum SectionIdentifier {
  case main
}
#endif
