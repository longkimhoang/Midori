//
//  UICollectionViewLayout+Home.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

#if os(iOS)
import Foundation
import SwiftUI

extension UICollectionViewLayout {
  static func home() -> UICollectionViewLayout {
    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
      sectionIndex, layoutEnvironment in

      guard let sectionIdentifier = SectionIdentifier(rawValue: sectionIndex) else {
        return nil
      }

      return switch sectionIdentifier {
      case .popular:
        .popular(layoutEnvironment: layoutEnvironment)
      case .latestUpdates:
        .latestUpdates(layoutEnvironment: layoutEnvironment)
      case .recentlyAdded:
        .recentlyAdded(layoutEnvironment: layoutEnvironment)
      }
    }

    let configuration = UICollectionViewCompositionalLayoutConfiguration()
    configuration.interSectionSpacing = 20
    configuration.contentInsetsReference = .layoutMargins

    return UICollectionViewCompositionalLayout(
      sectionProvider: sectionProvider, configuration: configuration
    )
  }
}
#endif
