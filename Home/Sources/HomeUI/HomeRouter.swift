//
//  HomeRouter.swift
//
//
//  Created by Long Kim on 28/3/24.
//

import CommonUI
import UIKit

@MainActor
public final class HomeRouter: Routing {
  private weak var navigationController: UINavigationController!

  public init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }

  public func start(context: Context) {
    navigationController.pushViewController(HomeViewController(), animated: false)

    if let activity = context.restorationActivity,
       let recentlyAddedPresented = activity
       .userInfo?[StateRestorationKeys.RecentlyAdded.presented] as? Bool,
       recentlyAddedPresented
    {
      navigationController.pushViewController(RecentlyAddedDetailViewController(), animated: false)
    }
  }

  public func updateStateRestorationActivity() {}
}
