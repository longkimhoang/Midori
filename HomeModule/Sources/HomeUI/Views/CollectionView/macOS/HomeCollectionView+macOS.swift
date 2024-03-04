//
//  HomeCollectionView+macOS.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

#if os(macOS)
import Foundation
import HomeDomain
import Persistence
import SnapKit
import SwiftUI

struct HomeCollectionView: NSViewRepresentable {
  let data: HomeData

  func makeNSView(context: Context) -> NSCollectionView {
    let collectionView = NSCollectionView()
    collectionView.collectionViewLayout = .home()
    context.coordinator.setupDataSource(for: collectionView)

    return collectionView
  }

  func updateNSView(_: NSCollectionView, context: Context) {
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
    var dataSource: NSCollectionViewDiffableDataSource<SectionIdentifier, NSManagedObjectID>!

    init(homeData: HomeData) {
      self.homeData = homeData
    }

    func setupDataSource(for collectionView: NSCollectionView) {
      collectionView.register(
        PopularMangaCollectionViewItem.self,
        forItemWithIdentifier: .popularManga
      )

      dataSource =
        NSCollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier in
          guard let self else { return nil }

          let section = SectionIdentifier(rawValue: indexPath.section)
          switch section {
          case .popular:
            guard let manga = homeData.popular[id: itemIdentifier] else {
              return nil
            }

            let item = collectionView.makeItem(withIdentifier: .popularManga, for: indexPath)
            if let item = item as? PopularMangaCollectionViewItem {
              item.configure(with: manga)
            }

            return item
          default:
            return nil
          }
        }
    }
  }
}

// MARK: - Collection View Items

extension NSUserInterfaceItemIdentifier {
  fileprivate static let popularManga =
    NSUserInterfaceItemIdentifier("HomeCollectionView.popularManga")
}

private final class PopularMangaCollectionViewItem: NSCollectionViewItem {
  private var hostingView: NSHostingView<PopularMangaView>!

  func configure(with manga: Manga) {
    if let hostingView {
      hostingView.rootView = PopularMangaView(manga: manga)
    } else {
      hostingView = NSHostingView(rootView: PopularMangaView(manga: manga))
      hostingView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(hostingView)
      hostingView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }
    }
  }
}
#endif
