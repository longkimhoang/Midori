//
//  MangaListCollectionView+DataSource.swift
//
//
//  Created by Long Kim on 29/4/24.
//

import IdentifiedCollections
import MangaList
import SwiftUI
import UIKit

extension MangaListCollectionView.Coordinator {
  func configureDataSource(collectionView: UICollectionView) {
    let listCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
        cell, _, manga in

        cell.contentConfiguration = UIHostingConfiguration {
          Text(manga.id.uuidString)
        }
      }

    let gridCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
        cell, _, manga in

        cell.contentConfiguration = UIHostingConfiguration {
          Text(manga.id.uuidString)
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

  func updateDataSource(with mangas: IdentifiedArrayOf<Manga>, animated: Bool = true) {
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(mangas.ids.elements, toSection: .main)

    dataSource.apply(snapshot, animatingDifferences: animated)
  }
}
