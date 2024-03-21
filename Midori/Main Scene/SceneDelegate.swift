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
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }

    let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity

    let window = UIWindow(windowScene: windowScene)
    self.window = window

    router = AppRouter(window: window)
    router?.start(restoringFrom: userActivity)

    // Remember this activity for later when this app quits or suspends.
    scene.userActivity = userActivity
  }
}
