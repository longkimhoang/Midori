//
//  HomeViewController.swift
//  UI
//
//  Created by Long Kim on 27/10/24.
//

import ComposableArchitecture
import MidoriFeatures
import UIKit

final class HomeViewController: UIViewController {
    private let store: StoreOf<Home>

    init(store: StoreOf<Home>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            await store.send(.fetchHomeData).finish()
        }
    }
}
