//
//  RecentlyAddedDetailViewController.swift
//
//
//  Created by Long Kim on 18/3/24.
//

import Combine
import HomeCore
import MangaListUI
import SnapKit
import UIKit

final class RecentlyAddedDetailViewController: UIViewController {
  @ViewLoading private var mangaListViewController: MangaListViewController
  private lazy var model = RecentlyAddedDetailModel()
  private lazy var cancellables: Set<AnyCancellable> = []

  init() {
    super.init(nibName: nil, bundle: nil)

    navigationItem.title = String(localized: "Recently added")
    navigationItem.largeTitleDisplayMode = .never
    navigationItem.rightBarButtonItems = []
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    mangaListViewController = MangaListViewController()

    addChild(mangaListViewController)
    mangaListViewController.didMove(toParent: self)

    view.addSubview(mangaListViewController.view)
    mangaListViewController.view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    navigationItem.rightBarButtonItems?.append(mangaListViewController.layoutChangeBarButtonItem)

    configureSubscribers()

    Task {
      model.fetchInitialMangas()
      await model.fetch()
    }
  }
}

// MARK: - Subscribers

private extension RecentlyAddedDetailViewController {
  func configureSubscribers() {
    model.$mangas
      .assign(to: &mangaListViewController.$mangas)

    mangaListViewController.listEndReachedPublisher
      .throttle(for: .milliseconds(300), scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] in
        Task {
          await self?.model.fetch()
        }
      }
      .store(in: &cancellables)
  }
}
