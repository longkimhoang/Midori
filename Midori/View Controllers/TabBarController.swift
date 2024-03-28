//
//  TabBarController.swift
//  Midori
//
//  Created by Long Kim on 28/3/24.
//

import ComposableArchitecture
import HomeUI
import UIKit

final class TabBarController: UITabBarController {
  private lazy var homeViewController = HomeUI.storyboard
    .instantiateInitialViewController { [unowned self] coder in
      MainActor.assumeIsolated {
        HomeViewControllerV2(coder: coder, store: store.scope(state: \.home, action: \.home))
      }
    }

  let store: StoreOf<AppFeature>

  init?(coder: NSCoder, store: StoreOf<AppFeature>) {
    self.store = store
    super.init(coder: coder)

    viewControllers = [
      homeViewController,
    ]
    .compactMap { $0 }
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
