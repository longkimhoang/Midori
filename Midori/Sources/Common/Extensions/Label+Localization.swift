//
//  Label+Localization.swift
//
//
//  Created by Long Kim on 4/5/24.
//

import SwiftUI

public extension Label where Title == Text, Icon == Image {
  init(_ titleKey: LocalizedStringKey, bundle: Bundle? = nil, systemImage: String) {
    self = Label {
      Text(titleKey, bundle: bundle)
    } icon: {
      Image(systemName: systemImage)
    }
  }
}
