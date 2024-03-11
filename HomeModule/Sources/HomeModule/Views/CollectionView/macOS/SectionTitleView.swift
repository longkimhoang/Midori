//
//  SectionTitleView.swift
//
//
//  Created by Long Kim on 11/3/24.
//

#if os(macOS)
import AppKit
import SnapKit

final class SectionTitleView: NSView, NSCollectionViewElement {
  private(set) lazy var label = NSTextField(labelWithString: "Placeholder title")

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    label.font = NSFont.systemFont(.title1)

    addSubview(label)
    label.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
#endif
