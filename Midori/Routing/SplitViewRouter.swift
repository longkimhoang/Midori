//
//  SplitViewRouter.swift
//  Midori
//
//  Created by Long Kim on 27/3/24.
//

import Combine
import CommonUI
import HomeUI
import UIKit

@MainActor
final class SplitViewRouter: Routing {
  weak var parent: (any Routing)?
  var children: [any Routing] = []

  private lazy var cancellables: Set<AnyCancellable> = []
  private weak var splitViewController: UISplitViewController!
  private lazy var homeViewController = HomeViewController()

  init(parent: some Routing, splitViewController: UISplitViewController) {
    self.parent = parent
    self.splitViewController = splitViewController
  }

  func start(restoringFrom restorationActivity: NSUserActivity? = nil) {
    guard let splitViewController else { return }

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

    let sidebarViewController = SidebarViewController(destination: initialDestination)
    splitViewController.setViewController(sidebarViewController, for: .primary)

    // Subscribes to the sidebar changes
    sidebarViewController.$destination
      .sink { [weak self] destination in
        guard let self else { return }

        switch destination {
        case .home:
          splitViewController.setViewController(homeViewController, for: .secondary)
        case .search:
          print("Should set search VC")
        }
      }
      .store(in: &cancellables)

    splitViewController
      .publisher(for: \.viewControllers)
      .first()
      .sink { [weak splitViewController] _ in
        if let viewController = splitViewController?
          .viewController(for: .secondary) as? StateRestorable
        {
          viewController.restoreState(from: restorationActivity)
        }
      }
      .store(in: &cancellables)

    #if !targetEnvironment(macCatalyst)
    let tabBarController = UITabBarController()
    splitViewController.setViewController(tabBarController, for: .compact)

    let tabRouter = TabRouter(parent: self, tabBarController: tabBarController)
    children.append(tabRouter)
    tabRouter.start(restoringFrom: restorationActivity)
    #endif
  }

  func updateStateRestorationActivity() {
    if splitViewController.isCollapsed {
      children.forEach { $0.updateStateRestorationActivity() }
    } else {
      if let viewController = splitViewController
        .viewController(for: .secondary) as? StateRestorable
      {
        viewController.updateStateRestorationActivity()
      }
    }
  }
}
