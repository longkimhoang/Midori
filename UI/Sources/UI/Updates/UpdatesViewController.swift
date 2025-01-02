//
//  UpdatesViewController.swift
//  UI
//
//  Created by Long Kim on 2/1/25.
//

import MidoriViewModels
import UIKit

final class UpdatesViewController: UIViewController {
    let viewModel: UpdatesViewModel

    init(model: UpdatesViewModel) {
        viewModel = model
        super.init(nibName: nil, bundle: nil)

        navigationItem.title = String(localized: "Updates", bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
