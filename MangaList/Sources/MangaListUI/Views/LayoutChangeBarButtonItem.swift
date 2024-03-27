//
//  LayoutChangeBarButtonItem.swift
//
//
//  Created by Long Kim on 27/3/24.
//

import Combine
import UIKit

public final class MangaLayoutChangeBarButtonItem: UIBarButtonItem {
  private var layoutChangeSubscriber: AnyCancellable?
  private var segmentedControl: UISegmentedControl {
    customView as! UISegmentedControl
  }

  @Published public var layout: MangaListLayout

  public init(layout: MangaListLayout = .list) {
    self.layout = layout
    super.init()

    let handler: UIActionHandler = { [weak self] action in
      guard let self,
            let segmentedControl = action.sender as? UISegmentedControl,
            let selection = MangaListLayout(rawValue: segmentedControl.selectedSegmentIndex)
      else { return }

      self.layout = selection
    }

    let actions = MangaListLayout.allCases.map { $0.changeAction(handler: handler) }
    let segmentedControl = UISegmentedControl(items: actions)
    segmentedControl.selectedSegmentIndex = layout.rawValue
    customView = segmentedControl

    layoutChangeSubscriber = $layout.map(\.rawValue)
      .assign(to: \.selectedSegmentIndex, on: segmentedControl)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension MangaListLayout {
  func changeAction(handler: @escaping UIActionHandler) -> UIAction {
    switch self {
    case .list:
      UIAction(
        title: String(localized: "List"),
        image: UIImage(systemName: "list.bullet"),
        handler: handler
      )
    case .grid:
      UIAction(
        title: String(localized: "Grid"),
        image: UIImage(systemName: "square.grid.2x2"),
        handler: handler
      )
    }
  }
}
