//
//  Label+Initializers.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import Foundation
import SwiftUI

public extension Label where Title == Text, Icon == Image {
  init(_ titleKey: LocalizedStringKey, bundle: Bundle? = nil, systemImage: String) {
    self.init(
      title: {
        Text(titleKey, bundle: bundle)
      },
      icon: {
        Image(systemName: systemImage)
      }
    )
  }
}
