//
//  SplitViewController.swift
//  Midori
//
//  Created by Long Kim on 28/3/24.
//

import ComposableArchitecture
import HomeUI
import SwiftUI
import UIKit

final class SplitViewController: UISplitViewController {
  private lazy var homeViewController = HomeUI.storyboard
    .instantiateInitialViewController { [unowned self] coder in
      MainActor.assumeIsolated {
        HomeViewControllerV2(coder: coder, store: store.scope(state: \.home, action: \.home))
      }
    }

  let store: StoreOf<AppFeature>

  init?(coder: NSCoder, store: StoreOf<AppFeature>, userActivity: NSUserActivity) {
    self.store = store
    super.init(coder: coder)

    let storyboard = UIStoryboard(name: "Main", bundle: nil)

    let sidebarViewController = storyboard
      .instantiateViewController(identifier: "Sidebar") { coder in
        SidebarViewControllerV2(coder: coder, store: store)
      }
    setViewController(sidebarViewController, for: .primary)

    let tabBarController = storyboard.instantiateViewController(identifier: "TabBar") { coder in
      TabBarController(coder: coder, store: store)
    }
    setViewController(tabBarController, for: .compact)

    self.userActivity = userActivity
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    observe { [weak self] in
      guard let self else { return }

      switch store.destination {
      case .home:
        setViewController(homeViewController, for: .secondary)
      case .search:
        break
      }
    }
  }
}

extension SplitViewController {
  override func updateUserActivityState(_ activity: NSUserActivity) {
    super.updateUserActivityState(activity)

    try? activity.setTypedPayload(
      StateRestorationPayload(selectedDestination: store.destination)
    )
  }
}
