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
  var router: AppRouter?

  func scene(
    _ scene: UIScene,
    willConnectTo _: UISceneSession,
    options _: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }

    let window = UIWindow(windowScene: windowScene)
    self.window = window

    router = AppRouter(window: window)
    router?.start()
  }
}
