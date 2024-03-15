//
//  HoverCursorModifier.swift
//
//
//  Created by Long Kim on 15/3/24.
//

#if os(macOS)
import SwiftUI

struct HoverCursorModifier: ViewModifier {
  let cursor: NSCursor

  func body(content: Content) -> some View {
    content
      .onHover { inside in
        if inside {
          cursor.push()
        } else {
          NSCursor.pop()
        }
      }
  }
}

extension View {
  /// Specifies the cursor to change to when hovering over this view.
  ///
  /// - Parameter cursor: The `NSCursor` to change into.
  public func hoverCursor(_ cursor: NSCursor) -> some View {
    modifier(HoverCursorModifier(cursor: cursor))
  }
}
#endif
