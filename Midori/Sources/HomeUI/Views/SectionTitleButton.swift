//
//  SectionTitleButton.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import SwiftUI

struct SectionTitleButton: View {
  let title: Text
  let action: () -> Void

  init(_ title: Text, action: @escaping () -> Void) {
    self.title = title
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      HStack(alignment: .firstTextBaseline) {
        title
        Image(systemName: "chevron.right")
          .foregroundStyle(.secondary)
        Spacer()
      }
      .font(.title)
      .imageScale(.small)
      .foregroundStyle(.foreground)
    }
    .buttonStyle(.borderless)
  }
}

extension SectionTitleButton {
  @_disfavoredOverload
  init(_ title: some StringProtocol, action: @escaping () -> Void) {
    self.init(Text(title), action: action)
  }

  init(_ titleKey: LocalizedStringKey, bundle: Bundle = .module, action: @escaping () -> Void) {
    self.init(Text(titleKey, bundle: bundle), action: action)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  let title = "Test"

  return SectionTitleButton(title) {
    print("Test")
  }
  .padding()
}
