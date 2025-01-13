//
//  UpdatesViewController+Layout.swift
//  UI
//
//  Created by Long Kim on 8/1/25.
//

import UIKit

extension UpdatesViewController {
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { _, layoutEnvironment in
            var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
            listConfig.headerMode = .firstItemInSection

            return NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
        }

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}
