//
//  SectionTitleView+macOS.swift
//
//
//  Created by Long Kim on 04/03/2024.
//

#if os(macOS)
import Foundation
import SnapKit
import SwiftUI

final class SectionTitleViewHost: NSView, NSCollectionViewElement {
  private var hostingView: NSHostingView<SectionTitleView>!

  func configure(title: String) {
    let titleView = SectionTitleView(title: title)
    if let hostingView {
      hostingView.rootView = titleView
    } else {
      hostingView = NSHostingView(rootView: titleView)
      addSubview(hostingView)
      hostingView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }
    }
  }
}

struct SectionTitleView: View {
  let title: String

  var body: some View {
    HStack {
      Text(title)
      Spacer()
    }
    .font(.title)
    .padding(EdgeInsets(top: 24, leading: 16, bottom: 8, trailing: 16))
  }
}
#endif
