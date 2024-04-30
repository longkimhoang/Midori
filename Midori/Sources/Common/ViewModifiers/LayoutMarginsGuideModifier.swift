//
//  LayoutMarginsGuideModifier.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import SwiftUI

public struct LayoutMarginsGuideModifier: ViewModifier {
  @State private var layoutMargins: EdgeInsets = .init()

  public func body(content: Content) -> some View {
    content
      .environment(\.layoutMarginsGuide, layoutMargins)
      .background {
        LayoutMarginsGuideProvidingView(layoutMargins: $layoutMargins)
      }
  }
}

public extension View {
  func providingLayoutMargins() -> some View {
    modifier(LayoutMarginsGuideModifier())
  }
}

public extension EnvironmentValues {
  var layoutMarginsGuide: EdgeInsets {
    get { self[LayoutMarginsGuideEnvironmentKey.self] }
    set { self[LayoutMarginsGuideEnvironmentKey.self] = newValue }
  }
}

// MARK: - Implementation

enum LayoutMarginsGuideEnvironmentKey: EnvironmentKey {
  static let defaultValue: EdgeInsets = .init()
}

struct LayoutMarginsGuideProvidingView: UIViewControllerRepresentable {
  @Binding var layoutMargins: EdgeInsets

  func makeUIViewController(context _: Context) -> MarginsUpdatingViewController {
    MarginsUpdatingViewController(
      onLayoutMarginsChange: {
        layoutMargins = $0
      }
    )
  }

  func updateUIViewController(_: MarginsUpdatingViewController, context _: Context) {}

  final class MarginsUpdatingViewController: UIViewController {
    let onLayoutMarginsChange: (EdgeInsets) -> Void

    init(onLayoutMarginsChange: @escaping (EdgeInsets) -> Void) {
      self.onLayoutMarginsChange = onLayoutMarginsChange
      super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewLayoutMarginsDidChange() {
      super.viewLayoutMarginsDidChange()

      let insets = EdgeInsets(view.directionalLayoutMargins)
      onLayoutMarginsChange(insets)
    }
  }
}
