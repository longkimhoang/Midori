//
//  MangaListViewController.swift
//
//
//  Created by Long Kim on 18/3/24.
//

import Combine
import CommonUI
import Database
import IdentifiedCollections
import SwiftUI
import UIKit

public final class MangaListViewController: UIViewController {
  @ViewLoading private var collectionView: UICollectionView
  @ViewLoading private var dataSource: UICollectionViewDiffableDataSource<
    SectionIdentifier,
    Manga.ID
  >!
  private lazy var listEndReachedSubject = PassthroughSubject<Void, Never>()
  private lazy var cancellables: Set<AnyCancellable> = []

  @Published public var mangas: IdentifiedArrayOf<Manga>
  @Published public var layout: MangaListLayout
  public var refresh: () async -> Void = {}
  public lazy var listEndReachedPublisher = listEndReachedSubject.eraseToAnyPublisher()

  public init(
    mangas: IdentifiedArrayOf<Manga> = [],
    layout: MangaListLayout = .list
  ) {
    self.mangas = mangas
    self.layout = layout

    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func loadView() {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: layout.collectionViewLayout
    )
    collectionView.delegate = self
    #if !targetEnvironment(macCatalyst)
    collectionView.refreshControl = UIRefreshControl(
      frame: .zero,
      primaryAction: UIAction { action in
        guard let refreshControl = action.sender as? UIRefreshControl else {
          return
        }

        Task { [weak self] in
          await self?.refresh()
          refreshControl.endRefreshing()
        }
      }
    )
    #endif

    view = collectionView
    self.collectionView = collectionView
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    setupDataSource()
    configureSubscribers()
  }
}

// MARK: - Subscribers

private extension MangaListViewController {
  func configureSubscribers() {
    $mangas
      .receive(on: DispatchQueue.main)
      .sink { [weak self] mangas in
        self?.updateDataSource(with: mangas)
      }
      .store(in: &cancellables)

    $layout
      .receive(on: DispatchQueue.main)
      .sink { [weak self] layout in
        self?.updateLayout(to: layout)
      }
      .store(in: &cancellables)
  }
}

// MARK: - Data Source

private extension MangaListViewController {
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

        guard let self, let manga = mangas[id: itemIdentifier] else { return nil }

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

private extension MangaListViewController {
  func updateLayout(to layout: MangaListLayout) {
    collectionView.setCollectionViewLayout(layout.collectionViewLayout, animated: true)
    var snapshot = dataSource.snapshot()
    snapshot.reconfigureItems(snapshot.itemIdentifiers)
    dataSource.apply(snapshot)
  }
}

// MARK: - Delegate

extension MangaListViewController: UICollectionViewDelegate {
  public func collectionView(
    _: UICollectionView,
    willDisplay _: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    guard indexPath.item == mangas.endIndex - 1 else { return }
    listEndReachedSubject.send()
  }
}

// MARK: - Helpers

private enum SectionIdentifier {
  case main
}

private extension MangaListLayout {
  var collectionViewLayout: UICollectionViewLayout {
    switch self {
    case .list: .mangaList()
    case .grid: .mangaGrid()
    }
  }
}
