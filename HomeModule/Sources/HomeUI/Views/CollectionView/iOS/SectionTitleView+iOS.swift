//
//  SectionTitleView+iOS.swift
//
//
//  Created by Long Kim on 04/03/2024.
//

#if os(iOS)
import Foundation
import SnapKit
import UIKit

final class SectionTitleView: UICollectionReusableView {
  private lazy var label = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(label)
    label.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(NSDirectionalEdgeInsets(
        top: 8,
        leading: 16,
        bottom: 8,
        trailing: 16
      ))
    }
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(title: String) {
    var attributedTitle = AttributedString(title)
    attributedTitle.font = UIFont.preferredFont(
      forTextStyle: .title1,
      compatibleWith: traitCollection
    )
    label.attributedText = NSAttributedString(attributedTitle)
    setNeedsDisplay()
  }
}
#endif
