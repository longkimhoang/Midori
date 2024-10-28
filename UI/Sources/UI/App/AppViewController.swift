//
//  AppViewController.swift
//  UI
//
//  Created by Long Kim on 27/10/24.
//

import ComposableArchitecture
import MidoriFeatures
import UIKit
import UIKitNavigation

public final class AppViewController: UITabBarController {
    private typealias Tab = App.State.Tab

    @UIBinding private var selectedTabIdentifier: String?
    private let store: StoreOf<App>

    private lazy var homeTab = UITab(
        title: String(localized: "Home", bundle: .module),
        image: UIImage(systemName: "house"),
        identifier: Tab.home.rawValue
    ) { [unowned self] _ in
        HomeNavigationViewController(store: store.scope(state: \.home, action: \.home))
    }

    public init(store: StoreOf<App>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        tabs = [homeTab]

        observe { [unowned self] in
            selectedTabIdentifier = store.selectedTab.rawValue
        }

        bind(selectedTab: $selectedTabIdentifier)
    }
}
