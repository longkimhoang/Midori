//
//  SceneDelegate+StateRestoration.swift
//  Midori
//
//  Created by Long Kim on 21/3/24.
//

import CommonUI
import UIKit

extension SceneDelegate {
  enum StateRestorationKeys {
    static let selectedDestination = "selectedDestination"
  }

  func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
    router?.updateStateRestorationActivity()
    return scene.userActivity
  }
}
