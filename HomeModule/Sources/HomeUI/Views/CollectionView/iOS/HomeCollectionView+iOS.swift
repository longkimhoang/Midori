//
//  HomeCollectionView+iOS.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

#if os(iOS)
import CoreData
import Foundation
import HomeDomain
import SwiftUI

struct HomeCollectionView: UIViewRepresentable {
  let data: HomeData

  func makeUIView(context: Context) -> UICollectionView {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .home())
    context.coordinator.setupDataSource(for: collectionView)

    return collectionView
  }

  func updateUIView(_: UICollectionView, context: Context) {
    var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, UUID>()
    snapshot.appendSections([.popular])
    snapshot.appendItems(data.popular.compactMap(\.mangaID), toSection: .popular)
    context.coordinator.dataSource.apply(snapshot)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  final class Coordinator {
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, UUID>!

    func setupDataSource(for collectionView: UICollectionView) {
      let popularMangaCellRegistration = UICollectionView.CellRegistration<
        UICollectionViewCell,
        UUID
      > { cell, _, item in
        cell.contentConfiguration = UIHostingConfiguration {
          PopularMangaView(id: item)
        }
      }

      dataSource =
        UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
          let section = SectionIdentifier(rawValue: indexPath.section)
          return switch section {
          case .popular:
            collectionView.dequeueConfiguredReusableCell(
              using: popularMangaCellRegistration,
              for: indexPath,
              item: itemIdentifier
            )
          default:
            nil
          }
        }
    }
  }
}
#endif
