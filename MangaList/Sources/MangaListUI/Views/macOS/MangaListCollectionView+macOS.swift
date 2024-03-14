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
    context.coordinator.setupDataSource(for: collectionView)

    let scrollView = NSScrollView()
    scrollView.documentView = collectionView
    return scrollView
  }

  func updateNSView(_: NSScrollView, context: Context) {
    context.coordinator.mangas = store.mangas
    context.coordinator.updateDataSource()
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(mangas: store.mangas)
  }

  final class Coordinator {
    var mangas: IdentifiedArrayOf<Manga>
    private var dataSource: NSCollectionViewDiffableDataSource<Int, Manga.ID>!

    init(mangas: IdentifiedArrayOf<Manga>) {
      self.mangas = mangas
    }

    func setupDataSource(for collectionView: NSCollectionView) {
      let mangaListCellRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, Manga> {
        item, _, manga in

        item.contentConfiguration = NSHostingConfiguration {
          Text(manga.title)
        }
        .background(.red)
      }
      dataSource =
        NSCollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier in

          guard let self, let manga = mangas[id: itemIdentifier] else { return nil }
          return collectionView.makeItem(
            using: mangaListCellRegistration,
            for: indexPath,
            element: manga
          )
        }
    }

    func updateDataSource() {
      var snapshot = NSDiffableDataSourceSnapshot<Int, Manga.ID>()
      snapshot.appendSections([0])
      snapshot.appendItems(mangas.map(\.id), toSection: 0)
      dataSource.apply(snapshot, animatingDifferences: true)
    }
  }
}
#endif
