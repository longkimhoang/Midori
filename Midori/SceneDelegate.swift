//
//  SceneDelegate.swift
//  Midori
//
//  Created by Long Kim on 18/3/24.
//

import HomeUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo _: UISceneSession,
    options _: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }

    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = configureSplitViewController()
    window?.makeKeyAndVisible()
  }

  func configureSplitViewController() -> UISplitViewController {
    let splitViewController = UISplitViewController(style: .doubleColumn)

    let homeViewController = HomeViewController()
    splitViewController.setViewController(configureTabBarController(), for: .compact)
    splitViewController.setViewController(SidebarViewController(), for: .primary)
    splitViewController.setViewController(homeViewController, for: .secondary)
    #if targetEnvironment(macCatalyst)
    splitViewController.primaryBackgroundStyle = .sidebar
    #endif

    return splitViewController
  }

  func configureTabBarController() -> UITabBarController {
    let tabBarController = UITabBarController()

    let homeNavigationController = UINavigationController(rootViewController: HomeViewController())
    homeNavigationController.navigationBar.prefersLargeTitles = true

    tabBarController.viewControllers = [
      homeNavigationController,
    ]

    return tabBarController
  }
}
