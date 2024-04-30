//
//  HomeCollectionView.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import ComposableArchitecture
import HomeCore
import SwiftUI

struct HomeCollectionView: UIViewControllerRepresentable {
  @Environment(\.refresh) private var refresh

  let store: StoreOf<HomeFeature>

  func makeUIViewController(context: Context) -> ViewController {
    let viewController = ViewController(coordinator: context.coordinator)
    context.coordinator.configureDataSource(collectionView: viewController.collectionView)
    viewController.collectionView.delegate = context.coordinator

    return viewController
  }

  func updateUIViewController(_ viewController: ViewController, context: Context) {
    if let data = store.fetchStatus.success {
      let animated = context.transaction.animation != nil
      context.coordinator.updateDataSource(with: data, animated: animated)
    }

    viewController.setNeedsUpdateContentUnavailableConfiguration()
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(store: store)
  }

  final class ViewController: UICollectionViewController {
    weak var coordinator: Coordinator!

    init(coordinator: Coordinator) {
      self.coordinator = coordinator

      super.init(collectionViewLayout: HomeCollectionView.layout)
      installsStandardGestureForInteractiveMovement = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      collectionView.preservesSuperviewLayoutMargins = true
    }
  }

  final class Coordinator: NSObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>

    let store: StoreOf<HomeFeature>
    var dataSource: DataSource!

    init(store: StoreOf<HomeFeature>) {
      self.store = store
    }
  }
}
