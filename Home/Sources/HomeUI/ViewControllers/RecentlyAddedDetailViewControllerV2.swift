//
//  RecentlyAddedDetailViewControllerV2.swift
//
//
//  Created by Long Kim on 28/3/24.
//

import Combine
import ComposableArchitecture
import HomeCore
import MangaListUI
import SnapKit
import UIKit

@ViewAction(for: RecentlyAddedDetailFeature.self)
final class RecentlyAddedDetailViewControllerV2: UIViewController {
  private lazy var layoutChangeBarButtonItem = MangaLayoutChangeBarButtonItem()
  private lazy var mangaListViewController = MangaListUI.storyboard
    .instantiateInitialViewController { [weak self] coder in
      guard let self else { return nil }
      return MainActor.assumeIsolated {
        MangaListViewControllerV2(
          coder: coder,
          store: self.store.scope(state: \.mangaList, action: \.mangaList)
        )
      }
    }!
  private lazy var cancellables: Set<AnyCancellable> = []

  let store: StoreOf<RecentlyAddedDetailFeature>

  init?(coder: NSCoder, store: StoreOf<RecentlyAddedDetailFeature>) {
    self.store = store
    super.init(coder: coder)

    navigationItem.rightBarButtonItems = [layoutChangeBarButtonItem]
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    embedMangaListViewController()
    configureSubscribers()

    send(.fetchInitialMangas)

    observe { [weak self] in
      guard let self else { return }

      if store.isFetching {
      } else {}
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    if isMovingFromParent {
      performSegue(withIdentifier: "UnwindToHome", sender: self)
    }
  }

  func embedMangaListViewController() {
    addChild(mangaListViewController)
    view.addSubview(mangaListViewController.view)

    mangaListViewController.view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    mangaListViewController.didMove(toParent: self)
  }
}

// MARK: - Subscribers

private extension RecentlyAddedDetailViewControllerV2 {
  func configureSubscribers() {
    layoutChangeBarButtonItem.$layout
      .sink { [weak self] in
        self?.store.send(.mangaList(.changeLayout($0)))
      }
      .store(in: &cancellables)
  }
}
