//
//  ScanlatorGroupLabel.swift
//
//
//  Created by Long Kim on 3/5/24.
//

import SwiftUI

public struct ScanlatorGroupLabel: View {
  public let name: String

  public init(name: String) {
    self.name = name
  }

  public var body: some View {
    Label(name, systemImage: "person.2.fill")
      .labelStyle(ScanlatorGroupLabelStyle())
  }
}

private struct ScanlatorGroupLabelStyle: LabelStyle {
  @Environment(\.font) var font

  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: 4) {
      configuration.icon
      configuration.title
    }
    .font(font ?? .subheadline)
    .imageScale(.small)
  }
}
