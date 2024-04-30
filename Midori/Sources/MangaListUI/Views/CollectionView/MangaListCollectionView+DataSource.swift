//
//  MangaListCollectionView+DataSource.swift
//
//
//  Created by Long Kim on 29/4/24.
//

import Common
import IdentifiedCollections
import MangaListCore
import Nuke
import SwiftUI
import UIKit

extension MangaListCollectionView.Coordinator {
  @MainActor
  func configureDataSource(collectionView: UICollectionView) {
    let pipeline = ImagePipeline.default
    let listCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
        [weak self] cell, indexPath, manga in

        guard let self else { return }

        let request = ImageRequest(url: manga.coverImageThumbnailURL)
        let image = pipeline.cache.cachedImage(for: request)?.image
        cell.contentConfiguration = UIHostingConfiguration {
          MangaListItemView(manga: manga, coverImage: image.map(Image.init))
        }
        .margins(.all, 16)
        .background {
          RoundedRectangle(cornerRadius: 16)
            .fill(ListItemBackgroundStyle())
        }

        if image == nil {
          Task {
            _ = try await pipeline.image(for: request)
            self.reconfigureItems(at: [indexPath])
          }
        }
      }

    let gridCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
        cell, indexPath, manga in

        let request = ImageRequest(url: manga.coverImageURL)
        let image = pipeline.cache.cachedImage(for: request)?.image
        cell.contentConfiguration = UIHostingConfiguration {
          MangaGridItemView(manga: manga, coverImage: image.map(Image.init))
        }
        .margins(.all, 0)

        if image == nil {
          Task {
            _ = try await pipeline.image(for: request)
            self.reconfigureItems(at: [indexPath])
          }
        }
      }

    dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
      [weak self] collectionView, indexPath, itemIdentifier in

      guard let self else { return nil }

      let layout = store.withState(\.layout)
      let mangas = store.withState(\.mangas)

      switch layout {
      case .list:
        return collectionView.dequeueConfiguredReusableCell(
          using: listCellRegistration,
          for: indexPath,
          item: mangas[id: itemIdentifier]
        )
      case .grid:
        return collectionView.dequeueConfiguredReusableCell(
          using: gridCellRegistration,
          for: indexPath,
          item: mangas[id: itemIdentifier]
        )
      }
    }
  }

  @MainActor
  func updateDataSource(with mangas: IdentifiedArrayOf<Manga>, animated: Bool = true) {
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(mangas.ids.elements, toSection: .main)

    dataSource.apply(snapshot, animatingDifferences: animated)
  }

  /// Reloads the whole data source, in anticipation of a layout change.
  @MainActor
  func reloadDataSourceForLayoutChange() {
    let snapshot = dataSource.snapshot()
    dataSource.applySnapshotUsingReloadData(snapshot)
  }

  @MainActor
  private func reconfigureItems(at indexPaths: [IndexPath]) {
    var snapshot = dataSource.snapshot()
    snapshot.reconfigureItems(indexPaths.compactMap(dataSource.itemIdentifier(for:)))

    dataSource.apply(snapshot, animatingDifferences: false)
  }
}
