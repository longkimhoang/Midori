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
import Persistence
import SwiftUI

struct HomeCollectionView: UIViewRepresentable {
  let data: HomeData

  func makeUIView(context: Context) -> UICollectionView {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .home())
    context.coordinator.setupDataSource(for: collectionView)

    return collectionView
  }

  func updateUIView(_: UICollectionView, context: Context) {
    context.coordinator.homeData = data

    var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, NSManagedObjectID>()
    snapshot.appendSections([.popular])
    snapshot.appendItems(data.popular.map(\.id), toSection: .popular)
    context.coordinator.dataSource.apply(snapshot)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(homeData: data)
  }

  final class Coordinator {
    var homeData: HomeData
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, NSManagedObjectID>!

    init(homeData: HomeData) {
      self.homeData = homeData
    }

    func setupDataSource(for collectionView: UICollectionView) {
      let popularMangaCellRegistration = UICollectionView.CellRegistration<
        UICollectionViewCell,
        Manga
      > { cell, _, item in
        cell.contentConfiguration = UIHostingConfiguration {
          PopularMangaView(manga: item)
        }
      }

      dataSource =
        UICollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier in
          guard let self else { return nil }

          let section = SectionIdentifier(rawValue: indexPath.section)
          switch section {
          case .popular:
            guard let manga = homeData.popular[id: itemIdentifier] else {
              return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
              using: popularMangaCellRegistration,
              for: indexPath,
              item: manga
            )
          default:
            return nil
          }
        }
    }
  }
}
#endif
