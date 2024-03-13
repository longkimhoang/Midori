//
//  SectionTitleNavigationLabelStyle.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import SwiftUI

struct SectionTitleNavigationLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack(alignment: .firstTextBaseline) {
      configuration.title
      configuration.icon
        .imageScale(.small)
        .foregroundStyle(.secondary)
    }
  }
}

extension LabelStyle where Self == SectionTitleNavigationLabelStyle {
  static var sectionTitleNavigation: SectionTitleNavigationLabelStyle {
    SectionTitleNavigationLabelStyle()
  }
}
