//
//  SceneDelegate.swift
//  App
//
//  Created by Long Kim on 18/10/24.
//

import ComposableArchitecture
import MidoriFeatures
import MidoriUI
import UIKit

public class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private lazy var store = Store(initialState: App.State()) {
        App()
    }

    public var window: UIWindow?

    public func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = AppViewController(store: store)
        window?.makeKeyAndVisible()
    }
}
