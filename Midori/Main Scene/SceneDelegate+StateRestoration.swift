//
//  SceneDelegate+StateRestoration.swift
//  Midori
//
//  Created by Long Kim on 21/3/24.
//

import CommonUI
import UIKit

enum StateRestorationKeys {
  static let selectedDestination = "selectedDestination"
}

extension SceneDelegate {
  func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
    router?.updateStateRestorationActivity()
    return scene.userActivity
  }
}

struct StateRestorationPayload: Codable {
  let selectedDestination: AppDestination
}
