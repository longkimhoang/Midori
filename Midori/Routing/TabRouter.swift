//
//  TabRouter.swift
//  Midori
//
//  Created by Long Kim on 27/3/24.
//

import HomeUI
import UIKit
import CommonUI

@MainActor
final class TabRouter: Routing {
  weak var parent: (any Routing)?
  private weak var tabBarController: UITabBarController!
  private lazy var homeViewController = HomeViewController()

  init(parent: some Routing, tabBarController: UITabBarController) {
    self.parent = parent
    self.tabBarController = tabBarController
  }

  func start(restoringFrom restorationActivity: NSUserActivity? = nil) {
    guard let tabBarController else { return }

    tabBarController.viewControllers = [
      UINavigationController(rootViewController: homeViewController)
    ]

    let initialDestination: AppDestination =
      if let restorationActivity,
      let selectedDestination = (
        restorationActivity
          .userInfo?[StateRestorationKeys.selectedDestination] as? Int
      ).flatMap(AppDestination.init) {
        selectedDestination
      } else {
        .home
      }
    tabBarController.selectedIndex = initialDestination.rawValue

    if let navigationController = tabBarController.selectedViewController as? UINavigationController,
       let viewController = navigationController.topViewController as? StateRestorable {
      viewController.restoreState(from: restorationActivity)
    }
  }

  func updateStateRestorationActivity() {
    if let navigationController = tabBarController.selectedViewController as? UINavigationController,
       let viewController = navigationController.topViewController as? StateRestorable {
      viewController.updateStateRestorationActivity()
    }
  }
}
