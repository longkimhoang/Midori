//
//  MangaDetailViewController+Layout.swift
//  UI
//
//  Created by Long Kim on 2/11/24.
//

import UIKit

extension MangaDetailViewController {
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
            [unowned self] sectionIndex, layoutEnvironment in

            guard let sectionIdentifier = SectionIdentifier(rawValue: sectionIndex) else {
                return nil
            }

            switch sectionIdentifier {
            case .chapters:
                return makeChaptersSection(layoutEnvironment: layoutEnvironment)
            }
        }

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.contentInsetsReference = .layoutMargins

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
    }

    private func makeChaptersSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)

        return NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: layoutEnvironment)
    }
}
