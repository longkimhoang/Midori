//
//  HomeCollectionView+macOS.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

#if os(macOS)
import Foundation
import HomeDomain
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
    var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, UUID>()
    snapshot.appendSections([.popular])
    snapshot.appendItems(data.popular.map(\.id), toSection: .popular)
    context.coordinator.dataSource.apply(snapshot)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  final class Coordinator {
    var dataSource: NSCollectionViewDiffableDataSource<SectionIdentifier, UUID>!

    func setupDataSource(for collectionView: NSCollectionView) {
      collectionView.register(
        PopularMangaCollectionViewItem.self,
        forItemWithIdentifier: .popularManga
      )

      dataSource =
        NSCollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
          let section = SectionIdentifier(rawValue: indexPath.section)
          switch section {
          case .popular:
            let item = collectionView.makeItem(withIdentifier: .popularManga, for: indexPath)
            if let item = item as? PopularMangaCollectionViewItem {
              item.configure(with: itemIdentifier)
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

  func configure(with item: UUID) {
    if let hostingView {
      hostingView.rootView = PopularMangaView(id: item)
    } else {
      hostingView = NSHostingView(rootView: PopularMangaView(id: item))
      hostingView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(hostingView)
      hostingView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }
    }
  }
}
#endif
