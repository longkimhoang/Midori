//
//  MangaListViewControllerV2.swift
//
//
//  Created by Long Kim on 28/3/24.
//

import ComposableArchitecture
import Database
import MangaListCore
import SwiftUI
import UIKit

@ViewAction(for: MangaListFeature.self)
public final class MangaListViewControllerV2: UIViewController {
  private var layout: MangaListCore.MangaListLayout
  @ViewLoading @IBOutlet private var collectionView: UICollectionView
  @ViewLoading private var dataSource: UICollectionViewDiffableDataSource<
    SectionIdentifier,
    Manga.ID
  >!

  public let store: StoreOf<MangaListFeature>

  public init?(coder: NSCoder, store: StoreOf<MangaListFeature>) {
    self.store = store
    layout = store.layout
    super.init(coder: coder)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    collectionView.collectionViewLayout = layout.collectionViewLayout
    #if !targetEnvironment(macCatalyst)
    collectionView.refreshControl = UIRefreshControl(
      frame: .zero,
      primaryAction: UIAction { [weak self] action in
        guard let self, let refreshControl = action.sender as? UIRefreshControl else {
          return
        }

        Task {
          await self.send(.refresh).finish()
          refreshControl.endRefreshing()
        }
      }
    )
    #endif

    setupDataSource()

    observe { [weak self] in
      guard let self else { return }

      updateDataSource(with: store.mangas)

      if store.layout != layout {
        layout = store.layout
        updateLayout(to: layout)
      }
    }
  }
}

// MARK: - Data Source

private extension MangaListViewControllerV2 {
  func setupDataSource() {
    let mangaListCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga>(url: { $0.thumbnailURL() }) {
        [weak self] cell, _, manga, image in

        guard let layout = self?.layout else { return }
        let image = image.map(Image.init)

        cell.contentConfiguration = UIHostingConfiguration {
          MangaItemView(manga: manga, image: image, layout: layout)
            .hoverEffect()
        }
        .margins(.all, 0)
      } onLoadSuccess: { [weak self] indexPath, _ in
        self?.reconfigureItems(at: [indexPath])
      }

    dataSource =
      UICollectionViewDiffableDataSource(collectionView: collectionView) {
        [weak self] collectionView, indexPath, itemIdentifier in

        guard let self, let manga = store.mangas[id: itemIdentifier] else { return nil }

        return collectionView.dequeueConfiguredReusableCell(
          using: mangaListCellRegistration,
          for: indexPath,
          item: manga
        )
      }
  }

  private func updateDataSource(with mangas: IdentifiedArrayOf<Manga>) {
    let itemIdentifiers = mangas.ids.elements
    guard dataSource.snapshot().itemIdentifiers != itemIdentifiers else { return }

    var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, Manga.ID>()
    snapshot.appendSections([.main])
    snapshot.appendItems(mangas.ids.elements)
    dataSource.apply(snapshot, animatingDifferences: true)
  }

  private func reconfigureItems(at indexPaths: [IndexPath]) {
    let itemIdentifiers = indexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
    var snaphot = dataSource.snapshot()
    snaphot.reconfigureItems(itemIdentifiers)
    dataSource.apply(snaphot, animatingDifferences: false)
  }
}

// MARK: - Layout change handling

private extension MangaListViewControllerV2 {
  func updateLayout(to layout: MangaListLayout) {
    collectionView.setCollectionViewLayout(layout.collectionViewLayout, animated: true)
    var snapshot = dataSource.snapshot()
    snapshot.reconfigureItems(snapshot.itemIdentifiers)
    dataSource.apply(snapshot)
  }
}

// MARK: - Delegate

extension MangaListViewControllerV2: UICollectionViewDelegate {
  public func collectionView(
    _: UICollectionView,
    willDisplay _: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    guard indexPath.item == store.mangas.endIndex - 1 else { return }
    send(.listEndReached)
  }
}

// MARK: - Helpers

private enum SectionIdentifier {
  case main
}

private extension MangaListCore.MangaListLayout {
  var collectionViewLayout: UICollectionViewLayout {
    switch self {
    case .list: .mangaList()
    case .grid: .mangaGrid()
    }
  }
}
