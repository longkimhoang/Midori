//
//  SidebarViewController.swift
//  Midori
//
//  Created by Long Kim on 18/3/24.
//

import UIKit

final class SidebarViewController: UIViewController {
  @ViewLoading private var collectionView: UICollectionView
  @ViewLoading private var dataSource: UICollectionViewDiffableDataSource<
    SectionIdentifier,
    NavigationDestination
  >

  init() {
    super.init(nibName: nil, bundle: nil)

    navigationItem.title = String(localized: "Midori")
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    let configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    view = collectionView
    self.collectionView = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupDataSource()
    applyInitialSnapshot()
  }
}

// MARK: - Data Source

private enum SectionIdentifier {
  case main
}

private enum NavigationDestination: CaseIterable {
  case home
}

private extension SidebarViewController {
  func setupDataSource() {
    let itemRegistration =
      UICollectionView.CellRegistration<UICollectionViewListCell, NavigationDestination> {
        cell, _, itemIdentifier in

        var configuration = cell.defaultContentConfiguration()
        switch itemIdentifier {
        case .home:
          configuration.text = String(localized: "Home")
          configuration.image = UIImage(systemName: "house")
        }

        cell.contentConfiguration = configuration
        cell.configurationUpdateHandler = { cell, state in
          guard var configuration = cell.contentConfiguration as? UIListContentConfiguration else {
            return
          }

          configuration = configuration.updated(for: state)
          if state.isSelected {
            switch itemIdentifier {
            case .home:
              configuration.image = UIImage(systemName: "house.fill")
            }
          }

          cell.contentConfiguration = configuration
        }
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
    snapshot.appendItems(NavigationDestination.allCases, toSection: .main)
    dataSource.apply(snapshot, animatingDifferences: false)

    collectionView.selectItem(at: [0, 0], animated: false, scrollPosition: [])
  }
}
