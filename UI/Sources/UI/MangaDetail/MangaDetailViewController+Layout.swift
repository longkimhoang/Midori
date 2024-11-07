//
//  MangaDetailViewController+Layout.swift
//  UI
//
//  Created by Long Kim on 2/11/24.
//

import UIKit

extension MangaDetailViewController {
    enum SupplementaryElementKind {
        static let mangaDetailHeader = "manga-detail-header"
    }

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
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.headerMode = .firstItemInSection
        listConfiguration.headerTopPadding = 0

        let section = NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: layoutEnvironment)

        return section
    }
}
