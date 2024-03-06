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

struct HomeCollectionView: UIViewControllerRepresentable {
  let data: HomeData

  func makeUIViewController(context: Context) -> HomeCollectionViewController {
    HomeCollectionViewController(coordinator: context.coordinator)
  }

  func updateUIViewController(_: HomeCollectionViewController, context: Context) {
    context.coordinator.homeData = data

    var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, NSManagedObjectID>()
    snapshot.appendSections([.popular, .latestUpdates, .recentlyAdded])
    snapshot.appendItems(data.popular.map(\.id), toSection: .popular)
    snapshot.appendItems(data.recentlyAdded.map(\.id), toSection: .recentlyAdded)
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
        .margins(.all, 0)
      }

      let recentlyAddedCellRegistration = UICollectionView.CellRegistration<
        UICollectionViewCell,
        Manga
      > { cell, _, item in
        cell.contentConfiguration = UIHostingConfiguration {
          RecentlyAddedMangaView(manga: item)
        }
        .margins(.all, 0)
      }

      dataSource =
        UICollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier in
          guard let self else { return nil }

          guard let section = SectionIdentifier(rawValue: indexPath.section) else { return nil }

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
          case .latestUpdates:
            guard let manga = homeData.recentlyAdded[id: itemIdentifier] else {
              return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
              using: popularMangaCellRegistration,
              for: indexPath,
              item: manga
            )
          case .recentlyAdded:
            guard let manga = homeData.recentlyAdded[id: itemIdentifier] else {
              return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
              using: recentlyAddedCellRegistration,
              for: indexPath,
              item: manga
            )
          }
        }

      let sectionTitleRegistration = UICollectionView
        .SupplementaryRegistration<SectionTitleView>(
          elementKind: SupplementaryItemKind
            .sectionTitle
        ) { sectionTitleView, _, indexPath in
          guard let section = SectionIdentifier(rawValue: indexPath.section) else { return }
          let localizedTitle: String.LocalizationValue = switch section {
          case .popular:
            "Popular new titles"
          case .latestUpdates:
            "Latest updates"
          case .recentlyAdded:
            "Recently added"
          }

          sectionTitleView.configure(title: String(localized: localizedTitle))
        }

      dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
        switch elementKind {
        case SupplementaryItemKind.sectionTitle:
          collectionView.dequeueConfiguredReusableSupplementary(
            using: sectionTitleRegistration,
            for: indexPath
          )
        default:
          nil
        }
      }
    }
  }

  final class HomeCollectionViewController: UIViewController {
    let coordinator: Coordinator

    init(coordinator: Coordinator) {
      self.coordinator = coordinator
      super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
      view = UICollectionView(frame: .zero, collectionViewLayout: .home())
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      view.layoutMargins = .zero
      coordinator.setupDataSource(for: view as! UICollectionView)
    }
  }
}
#endif
