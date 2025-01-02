//
//  AppViewController.swift
//  UI
//
//  Created by Long Kim on 27/10/24.
//

import Combine
import Dependencies
import MidoriViewModels
import SwiftUI
import UIKit

public final class AppViewController: UITabBarController {
    private typealias Tab = AppViewModel.Tab

    private lazy var cancellables: Set<AnyCancellable> = []
    private lazy var viewModel = AppViewModel()

    private lazy var homeTab = UITab(
        title: String(localized: "Home", bundle: .module),
        image: UIImage(systemName: "house"),
        identifier: Tab.home.rawValue
    ) { [unowned self] _ in
        return UINavigationController(rootViewController: HomeViewController(model: viewModel.home))
    }

    private lazy var feedTab = UITab(
        title: String(localized: "Updates", bundle: .module),
        image: UIImage(systemName: "bell"),
        identifier: Tab.updates.rawValue
    ) { [unowned self] _ in
        UIViewController()
    }

    private lazy var profileTab = UITab(
        title: String(localized: "Profile", bundle: .module),
        image: UIImage(systemName: "person.crop.circle"),
        identifier: Tab.profile.rawValue
    ) { [unowned self] _ in
        let profileView = ProfileView(model: viewModel.profile)
            .environmentObject(viewModel.account)

        return UINavigationController(rootViewController: UIHostingController(rootView: profileView))
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        tabs = [homeTab, feedTab, profileTab]

        viewModel.$selectedTab
            .removeDuplicates()
            .sink { [unowned self] identifier in
                selectedTab = tab(forIdentifier: identifier.rawValue)
            }
            .store(in: &cancellables)

        Task {
            try await viewModel.account.initializeAuthState()
        }
    }
}

extension AppViewController: UITabBarControllerDelegate {
    public func tabBarController(_: UITabBarController, didSelectTab selectedTab: UITab, previousTab _: UITab?) {
        if let tab = Tab(rawValue: selectedTab.identifier) {
            viewModel.selectedTab = tab
        }
    }
}
