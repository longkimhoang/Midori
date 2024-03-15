//
//  MangaListCollectionView+iOS.swift
//
//
//  Created by Long Kim on 15/3/24.
//

#if os(iOS)
import CommonUI
import ComposableArchitecture
import Database
import MangaListCore
import SwiftData
import SwiftUI

struct MangaListCollectionView: UIViewRepresentable {
  let store: StoreOf<MangaListFeature>

  func makeUIView(context: Context) -> UICollectionView {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .mangaList())
    collectionView.delegate = context.coordinator
    context.coordinator.setupDataSource(for: collectionView)

    return collectionView
  }

  func updateUIView(_: UICollectionView, context _: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(store: store)
  }

  @ViewAction(for: MangaListFeature.self)
  final class Coordinator: NSObject {
    let store: StoreOf<MangaListFeature>
    private var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, Manga.ID>!

    init(store: StoreOf<MangaListFeature>) {
      self.store = store
    }

    func setupDataSource(for collectionView: UICollectionView) {
      let mangaListCellRegistration =
        UICollectionView.CellRegistration<UICollectionViewCell, Manga>(url: { $0.thumbnailURL() }) {
          cell, _, manga, image in

          cell.contentConfiguration = UIHostingConfiguration {
            MangaListItemView(manga: manga, coverImage: image.map(Image.init))
          }
          .margins(.all, 0)
        } onLoadSuccess: { [weak self] indexPath, _ in
          self?.reconfigureItems(at: CollectionOfOne(indexPath))
        }

      dataSource =
        UICollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier in

          guard let self, let manga = store.mangas[id: itemIdentifier] else { return nil }
          return collectionView.dequeueConfiguredReusableCell(
            using: mangaListCellRegistration,
            for: indexPath,
            item: manga
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

    private func reconfigureItems(at indexPaths: some Collection<IndexPath>) {
      let itemIdentifiers = indexPaths.compactMap(dataSource.itemIdentifier(for:))
      var snaphot = dataSource.snapshot()
      snaphot.reconfigureItems(itemIdentifiers)
      dataSource.apply(snaphot, animatingDifferences: false)
    }
  }
}

extension MangaListCollectionView.Coordinator: UICollectionViewDelegate {
  func collectionView(
    _: UICollectionView,
    willDisplay _: UICollectionViewCell,
    forItemAt indexPath: IndexPath
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
