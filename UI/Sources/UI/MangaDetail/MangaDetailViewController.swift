//
//  MangaDetailViewController.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import ComposableArchitecture
import MidoriFeatures
import UIKit

final class MangaDetailViewController: UIViewController {
    let store: StoreOf<MangaDetail>

    init(store: StoreOf<MangaDetail>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
