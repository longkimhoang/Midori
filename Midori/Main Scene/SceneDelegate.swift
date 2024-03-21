//
//  SceneDelegate.swift
//  Midori
//
//  Created by Long Kim on 18/3/24.
//

import CommonUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate,
  StateRestorationActivityTypeProviding
{
  var window: UIWindow?
  var router: AppRouter?

  static let activityType = "com.longkimhoang.Midori.mainActivity"

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options _: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }

    let window = UIWindow(windowScene: windowScene)
    self.window = window

    router = AppRouter(window: window)
    router?.start(restoringFrom: session.stateRestorationActivity)
  }
}
