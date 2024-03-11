//
//  NSCollectionViewLayout+Home.swift
//
//
//  Created by Long Kim on 11/3/24.
//

#if os(macOS)
import SwiftUI

extension NSCollectionViewLayout {
  static func home() -> NSCollectionViewLayout {
    let sectionProvider: NSCollectionViewCompositionalLayoutSectionProvider = {
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

    let configuration = NSCollectionViewCompositionalLayoutConfiguration()
    configuration.interSectionSpacing = 20

    return NSCollectionViewCompositionalLayout(
      sectionProvider: sectionProvider, configuration: configuration
    )
  }
}
#endif
