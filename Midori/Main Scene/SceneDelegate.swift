//
//  SceneDelegate.swift
//  Midori
//
//  Created by Long Kim on 18/3/24.
//

import CommonUI
import ComposableArchitecture
import HomeCore
import SwiftUI
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

    let userActivity = session.stateRestorationActivity ??
      NSUserActivity(activityType: SceneDelegate.activityType)

    let window = UIWindow(windowScene: windowScene)
    self.window = window

    router = AppRouter(window: window)
//    router?.start(restoringFrom: userActivity)

    let store = Store(initialState: AppFeature.State(restoringFrom: userActivity)) {
      AppFeature()
    }

    let rootViewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateInitialViewController { coder in
        SplitViewController(coder: coder, store: store, userActivity: userActivity)
      }

    window.rootViewController = rootViewController
    window.makeKeyAndVisible()

    // Remember this activity for later when this app quits or suspends.
    scene.userActivity = userActivity
  }
}

private extension AppFeature.State {
  init(restoringFrom activity: NSUserActivity) {
    if let payload = try? activity.typedPayload(StateRestorationPayload.self) {
      self.init(destination: payload.selectedDestination)
    } else {
      self.init()
    }
  }
}
