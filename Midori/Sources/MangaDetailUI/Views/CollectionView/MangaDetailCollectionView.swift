//
//  MangaDetailCollectionView.swift
//
//
//  Created by Long Kim on 2/5/24.
//

import ComposableArchitecture
import MangaDetailCore
import SwiftUI

struct MangaDetailCollectionView: UIViewControllerRepresentable {
  let store: StoreOf<MangaDetailFeature>

  func makeUIViewController(context: Context) -> ViewController {
    ViewController(coordinator: context.coordinator)
  }

  func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    if let mangaFeed = store.fetchStatus.success {
      context.coordinator.updateDataSource(with: mangaFeed)
    }

    uiViewController.setNeedsUpdateContentUnavailableConfiguration()
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(store: store)
  }

  final class ViewController: UICollectionViewController {
    weak var coordinator: Coordinator!

    init(coordinator: Coordinator!) {
      self.coordinator = coordinator
      super.init(collectionViewLayout: Self.layout)

      coordinator.configureDataSource(collectionView: collectionView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }

  final class Coordinator: NSObject {
    typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemIdentifier>

    let store: StoreOf<MangaDetailFeature>
    var dataSource: DataSource!
    weak var collectionView: UICollectionView!

    init(store: StoreOf<MangaDetailFeature>) {
      self.store = store
    }
  }
}
