//
//  HomeCollectionView+Layout.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import UIKit

extension HomeCollectionView {
  static var layout: UICollectionViewLayout {
    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
      sectionIndex, layoutEnvironment in

      guard let sectionIdentifier = SectionIdentifier(rawValue: sectionIndex) else {
        return nil
      }

      return switch sectionIdentifier {
      case .popular: popularSection()
      case .latestUpdates: latestUpdatesSection(layoutEnvironment: layoutEnvironment)
      case .recentlyAdded: recentlyAddedSection()
      }
    }

    let layoutConfiguration = UICollectionViewCompositionalLayoutConfiguration()
    layoutConfiguration.interSectionSpacing = 20
    layoutConfiguration.contentInsetsReference = .layoutMargins
    let layout = UICollectionViewCompositionalLayout(
      sectionProvider: sectionProvider,
      configuration: layoutConfiguration
    )

    return layout
  }

  // MARK: - Sections

  static func popularSection() -> NSCollectionLayoutSection {
    // Item
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    // Group
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(200)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 32
    section.orthogonalScrollingBehavior = .groupPaging

    return section
  }

  static func latestUpdatesSection(
    layoutEnvironment: NSCollectionLayoutEnvironment
  ) -> NSCollectionLayoutSection {
    // Item
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(100)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    // Group
    let groupWidth = layoutEnvironment.traitCollection.horizontalSizeClass == .compact ? 1 : 0.5
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(groupWidth),
      heightDimension: .estimated(300)
    )
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: groupSize,
      repeatingSubitem: item,
      count: 3
    )

    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging

    return section
  }

  static func recentlyAddedSection() -> NSCollectionLayoutSection {
    // Item
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    // Group
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .absolute(128),
      heightDimension: .estimated(240)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 16
    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

    return section
  }
}
