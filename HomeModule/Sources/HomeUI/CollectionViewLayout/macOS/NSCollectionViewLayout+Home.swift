//
//  NSCollectionViewLayout+Home.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

#if os(macOS)
  import Foundation
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
          NSCollectionLayoutSection.popular(layoutEnvironment: layoutEnvironment)
        default:
          nil
        }
      }

      let configuration = NSCollectionViewCompositionalLayoutConfiguration()
      configuration.interSectionSpacing = 20

      return NSCollectionViewCompositionalLayout(
        sectionProvider: sectionProvider, configuration: configuration)
    }
  }
#endif
