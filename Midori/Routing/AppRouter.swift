//
//  AppRouter.swift
//  Midori
//
//  Created by Long Kim on 19/3/24.
//

import Combine
import CommonUI
import Foundation
import HomeUI
import UIKit

@MainActor
final class AppRouter: ObservableObject, Routing {
  var children: [any Routing] = []

  private weak var window: UIWindow?
  private lazy var splitViewController = UISplitViewController(style: .doubleColumn)
  private lazy var cancellables: Set<AnyCancellable> = []

  init(window: UIWindow) {
    self.window = window
  }

  func start(restoringFrom activity: NSUserActivity? = nil) {
    guard let window else { return }

    #if targetEnvironment(macCatalyst)
    splitViewController.primaryBackgroundStyle = .sidebar
    #endif

    let splitViewRouter = SplitViewRouter(parent: self, splitViewController: splitViewController)
    children.append(splitViewRouter)

    splitViewRouter.start(restoringFrom: activity)

    window.rootViewController = splitViewController
    window.makeKeyAndVisible()
  }

  func updateStateRestorationActivity() {
    children.forEach { $0.updateStateRestorationActivity() }
  }
}
