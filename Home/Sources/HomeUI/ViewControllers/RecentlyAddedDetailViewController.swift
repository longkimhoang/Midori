//
//  RecentlyAddedDetailViewController.swift
//
//
//  Created by Long Kim on 18/3/24.
//

import Combine
import CommonUI
import HomeCore
import MangaListUI
import SnapKit
import UIKit

final class RecentlyAddedDetailViewController: UIViewController {
  @ViewLoading private var mangaListViewController: MangaListViewController
  private lazy var model = RecentlyAddedDetailModel()
  private lazy var cancellables: Set<AnyCancellable> = []
  private lazy var layoutChangeBarButtonItem = MangaLayoutChangeBarButtonItem()

  init() {
    super.init(nibName: nil, bundle: nil)

    navigationItem.title = String(localized: "Recently added")
    navigationItem.largeTitleDisplayMode = .never
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    mangaListViewController = MangaListViewController()
    mangaListViewController.refresh = { [weak self] in
      await self?.model.refresh()
    }

    addChild(mangaListViewController)
    mangaListViewController.didMove(toParent: self)

    view.addSubview(mangaListViewController.view)
    mangaListViewController.view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    navigationItem.rightBarButtonItems = [layoutChangeBarButtonItem]
    #if targetEnvironment(macCatalyst)
    navigationItem.rightBarButtonItems?.append(
      UIBarButtonItem(systemItem: .refresh, primaryAction: UIAction { [weak self] _ in
        Task {
          await self?.model.refresh()
        }
      })
    )
    #endif

    configureSubscribers()

    Task {
      await model.fetchInitialMangas()
    }
  }

  override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)

    #if !targetEnvironment(macCatalyst)
    view.window?.windowScene?.title = String(localized: "Recently added")
    #endif
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    updateStateRestorationActivity()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    #if !targetEnvironment(macCatalyst)
    view.window?.windowScene?.title = nil
    #endif

    if let userActivity = view.window?.windowScene?.userActivity {
      userActivity.userInfo?.removeValue(forKey: StateRestorationKeys.RecentlyAdded.presented)
      userActivity.userInfo?.removeValue(
        forKey: StateRestorationKeys.RecentlyAdded.selectedListLayout
      )
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

    layoutChangeBarButtonItem.$layout
      .assign(to: &mangaListViewController.$layout)
  }
}

// MARK: - State restoration

extension RecentlyAddedDetailViewController: StateRestorable {
  func updateStateRestorationActivity() {
    guard let windowScene = view.window?.windowScene,
          let delegate = windowScene.delegate
          as? (UIWindowSceneDelegate & StateRestorationActivityTypeProviding)
    else {
      return
    }

    let userActivity = windowScene.userActivity ??
      NSUserActivity(activityType: type(of: delegate).activityType)

    let layout = mangaListViewController.layout
    userActivity.addUserInfoEntries(from: [
      StateRestorationKeys.RecentlyAdded.presented: true,
      StateRestorationKeys.RecentlyAdded.selectedListLayout: layout.rawValue,
    ])

    windowScene.userActivity = userActivity
  }

  func restoreState(from activity: NSUserActivity?) {
    guard let userInfo = activity?.userInfo else { return }

    if let rawLayout = userInfo[StateRestorationKeys.RecentlyAdded.selectedListLayout] as? Int,
       let layout = MangaListLayout(rawValue: rawLayout)
    {
      layoutChangeBarButtonItem.layout = layout
    }
  }
}
