//
//  Button+Localization.swift
//
//
//  Created by Long Kim on 4/5/24.
//

import SwiftUI

public extension Button where Label == Text {
  init(_ titleKey: LocalizedStringKey, bundle: Bundle? = nil, action: @escaping () -> Void) {
    self = Button(action: action) {
      Text(titleKey, bundle: bundle)
    }
  }
}

public extension Button where Label == SwiftUI.Label<Text, Image> {
  init(
    _ titleKey: LocalizedStringKey,
    bundle: Bundle? = nil,
    systemImage: String,
    action: @escaping () -> Void
  ) {
    self = Button(action: action) {
      Label(titleKey, bundle: bundle, systemImage: systemImage)
    }
  }
}
