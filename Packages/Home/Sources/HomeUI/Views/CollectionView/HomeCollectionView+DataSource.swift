//
//  HomeCollectionView+DataSource.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Home
import SwiftUI

extension HomeCollectionView.Coordinator {
  func configureDataSource(collectionView: UICollectionView) {
    let popularMangaCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
        cell, _, manga in

        cell.preservesSuperviewLayoutMargins = true
        cell.contentConfiguration = UIHostingConfiguration {
          Text(manga.name.localized(for: .autoupdatingCurrent))
        }
        .background(.red)
      }

    let recentlyAddedMangaCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
        cell, _, manga in

        cell.preservesSuperviewLayoutMargins = true
        cell.contentConfiguration = UIHostingConfiguration {
          Text(manga.name.localized(for: .autoupdatingCurrent))
        }
        .background(.green)
      }

    dataSource = DataSource(collectionView: collectionView) {
      [weak self] collectionView, indexPath, itemIdentifier in

      guard let self, let data = store.withState(\.fetchStatus.success) else {
        return nil
      }

      switch itemIdentifier {
      case let .popular(id):
        guard let manga = data.popularMangas[id: id] else {
          return nil
        }

        return collectionView.dequeueConfiguredReusableCell(
          using: popularMangaCellRegistration,
          for: indexPath,
          item: manga
        )
      case let .recentlyAdded(id):
        guard let manga = data.recentlyAddedMangas[id: id] else {
          return nil
        }

        return collectionView.dequeueConfiguredReusableCell(
          using: recentlyAddedMangaCellRegistration,
          for: indexPath,
          item: manga
        )
      }
    }
  }

  func updateDataSource(with data: HomeData, animated: Bool = true) {
    var snapshot = Snapshot()
    snapshot.appendSections([.popular, .recentlyAdded])
    snapshot.appendItems(data.popularMangas.ids.map { .popular($0) }, toSection: .popular)
    snapshot.appendItems(
      data.recentlyAddedMangas.ids.map { .recentlyAdded($0) },
      toSection: .recentlyAdded
    )

    dataSource.apply(snapshot, animatingDifferences: animated)
  }
}
