//
//  MangaListCollectionView.swift
//
//
//  Created by Long Kim on 29/4/24.
//

import ComposableArchitecture
import MangaList
import SwiftUI

struct MangaListCollectionView: UIViewControllerRepresentable {
  let store: StoreOf<MangaListFeature>

  func makeUIViewController(context: Context) -> ViewController {
    let initialLayout = store.withState(\.layout)
    let viewController = ViewController(
      initialLayout: initialLayout,
      coordinator: context.coordinator
    )
    context.coordinator.configureDataSource(collectionView: viewController.collectionView)

    return viewController
  }

  func updateUIViewController(_ viewController: ViewController, context: Context) {
    context.coordinator.updateDataSource(
      with: store.mangas,
      animated: context.transaction.animation != nil
    )

    if viewController.layout != store.layout {
      let collectionViewLayout = ViewController.layout(for: store.layout)
      viewController.collectionView
        .setCollectionViewLayout(collectionViewLayout, animated: false) { completed in
          if completed {
            viewController.layout = store.layout
          }
        }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(store: store)
  }

  final class ViewController: UICollectionViewController {
    var layout: MangaListFeature.Layout
    weak var coordinator: Coordinator!

    init(initialLayout: MangaListFeature.Layout, coordinator: Coordinator) {
      layout = initialLayout
      self.coordinator = coordinator

      super.init(collectionViewLayout: Self.layout(for: initialLayout))
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
    typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifier, Manga.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, Manga.ID>

    let store: StoreOf<MangaListFeature>
    var dataSource: DataSource!

    init(store: StoreOf<MangaListFeature>) {
      self.store = store
    }
  }
}

// MARK: - Helpers

private extension MangaListCollectionView.ViewController {
  static func layout(for layout: MangaListFeature.Layout) -> UICollectionViewLayout {
    switch layout {
    case .grid: gridLayout
    case .list: listLayout
    }
  }
}
