//
//  HomeNavigationViewController.swift
//  UI
//
//  Created by Long Kim on 28/10/24.
//

import ComposableArchitecture
import MidoriFeatures
import UIKit
import UIKitNavigation

final class HomeNavigationViewController: NavigationStackController {
    private var store: StoreOf<Home>!

    convenience init(store: StoreOf<Home>) {
        @UIBindable var store = store

        self.init(path: $store.scope(state: \.path, action: \.path)) {
            HomeViewController(store: store)
        } destination: { store in
            switch store.case {
            case let .mangaDetail(store):
                let viewController = MangaDetailViewController(store: store)
                viewController.preferredTransition = .zoom { context in
                    if let source = context.sourceViewController as? HomeViewController {
                        return source.transitionSourceView
                    }

                    return nil
                }

                return viewController
            }
        }

        self.store = store
    }
}
