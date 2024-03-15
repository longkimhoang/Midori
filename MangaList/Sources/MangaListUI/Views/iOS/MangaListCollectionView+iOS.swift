//
//  File.swift
//  
//
//  Created by Long Kim on 15/3/24.
//

#if os(iOS)
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
      let mangaListCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
        cell, _, manga in

        cell.contentConfiguration = UIHostingConfiguration {
          MangaListItemView(manga: manga, coverImage: nil)
        }
        .margins(.all, 0)
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
  }
}

extension MangaListCollectionView.Coordinator: UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
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
