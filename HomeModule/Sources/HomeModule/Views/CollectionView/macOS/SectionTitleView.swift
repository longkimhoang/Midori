//
//  SectionTitleView.swift
//
//
//  Created by Long Kim on 11/3/24.
//

#if os(macOS)
import AppKit

final class SectionTitleView: NSView, NSCollectionViewElement {
  @IBOutlet var label: NSTextField!
}
#endif
