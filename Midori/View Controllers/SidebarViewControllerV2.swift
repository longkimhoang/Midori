//
//  SidebarViewControllerV2.swift
//  Midori
//
//  Created by Long Kim on 28/3/24.
//

import ComposableArchitecture
import UIKit

final class SidebarViewControllerV2: UIViewController {
  @ViewLoading @IBOutlet private var collectionView: UICollectionView
  @ViewLoading private var dataSource: UICollectionViewDiffableDataSource<
    SectionIdentifier,
    AppDestination
  >
  let store: StoreOf<AppFeature>

  init?(coder: NSCoder, store: StoreOf<AppFeature>) {
    self.store = store
    super.init(coder: coder)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(
      using: UICollectionLayoutListConfiguration(appearance: .sidebar)
    )

    setupDataSource()
    applyInitialSnapshot()

    observe { [weak self] in
      guard let self else { return }

      if let indexPath = dataSource.indexPath(for: store.destination) {
        let isSelected = collectionView.indexPathsForSelectedItems
          .map { $0.contains(indexPath) } ?? false
        if !isSelected {
          collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
      }
    }
  }
}

// MARK: - Data source

private enum SectionIdentifier {
  case main
}

private extension SidebarViewControllerV2 {
  func setupDataSource() {
    let itemRegistration =
      UICollectionView.CellRegistration<UICollectionViewListCell, AppDestination> {
        cell, _, itemIdentifier in

        var configuration = cell.defaultContentConfiguration()
        switch itemIdentifier {
        case .home:
          configuration.text = String(localized: "Home")
          configuration.image = UIImage(systemName: "house")
        case .search:
          configuration.text = String(localized: "Search")
          configuration.image = UIImage(systemName: "magnifyingglass")
        }

        cell.contentConfiguration = configuration
      }

    dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
      collectionView, indexPath, itemIdentifier in

      collectionView.dequeueConfiguredReusableCell(
        using: itemRegistration,
        for: indexPath,
        item: itemIdentifier
      )
    }
  }

  func applyInitialSnapshot() {
    var snapshot = dataSource.snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(AppDestination.allCases, toSection: .main)
    dataSource.apply(snapshot, animatingDifferences: false)
  }
}

// MARK: - Delegate

extension SidebarViewControllerV2: UICollectionViewDelegate {
  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let destination = dataSource.itemIdentifier(for: indexPath) else {
      return
    }

    store.send(.setDestination(destination))
  }
}
