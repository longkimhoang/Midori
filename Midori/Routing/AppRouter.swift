//
//  AppRouter.swift
//  Midori
//
//  Created by Long Kim on 19/3/24.
//

import Combine
import Foundation
import HomeUI
import UIKit

@MainActor
final class AppRouter: ObservableObject {
  private weak var window: UIWindow?
  private lazy var splitViewController = UISplitViewController(style: .doubleColumn)
  private lazy var tabBarController = UITabBarController()

  private lazy var cancellables: Set<AnyCancellable> = []

  @Published var destination: AppDestination = .home

  init(window: UIWindow) {
    self.window = window
  }

  func start(
    traitCollection: UITraitCollection
  ) {
    guard let window else { return }

    #if targetEnvironment(macCatalyst)
    splitViewController?.primaryBackgroundStyle = .sidebar
    #endif

    // MARK: Sidebar

    let sidebarViewController = SidebarViewController(destination: destination)
    // Publishes destination changes to the sidebar
    $destination.assign(to: &sidebarViewController.$destination)
    // Subscribes to the sidebar changes
    sidebarViewController.$destination
      .removeDuplicates()
      .sink { [weak self] destination in
        guard let self else { return }

        switch destination {
        case .home:
          splitViewController.setViewController(HomeViewController(), for: .secondary)
        case .search:
          print("Should set search VC")
        }
      }
      .store(in: &cancellables)

    splitViewController.setViewController(sidebarViewController, for: .primary)

    // MARK: Tab bar

    let tabBarController = UITabBarController()
    let homeNavigationController = UINavigationController(rootViewController: HomeViewController())
    tabBarController.viewControllers = [
      homeNavigationController
    ]
    // Publishes destination changes to the tab bar
    $destination
      .map(\.rawValue)
      .assign(to: \.selectedIndex, on: tabBarController)
      .store(in: &cancellables)

    splitViewController.setViewController(tabBarController, for: .compact)

    window.rootViewController = splitViewController
    window.makeKeyAndVisible()
  }
}
