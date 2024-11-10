//
//  AppViewController.swift
//  UI
//
//  Created by Long Kim on 27/10/24.
//

import Combine
import MidoriViewModels
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
        UINavigationController(rootViewController: HomeViewController())
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        tabs = [homeTab]

        viewModel.$selectedTab
            .sink { [unowned self] identifier in
                selectedTab = tab(forIdentifier: identifier.rawValue)
            }
            .store(in: &cancellables)
    }
}
