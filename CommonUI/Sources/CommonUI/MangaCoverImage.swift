//
//  MangaCoverImage.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import SwiftUI

public struct MangaCoverImage<Content: View>: View {
  let content: () -> Content
  let width: CGFloat
  let aspectRatio: CGFloat
  let cornerRadius: CGFloat
  let bordered: Bool

  public init(
    @ViewBuilder content: @escaping () -> Content,
    width: CGFloat,
    aspectRatio: CGFloat = 0.7,
    cornerRadius: CGFloat = 8,
    bordered: Bool = true
  ) {
    self.content = content
    self.width = width
    self.aspectRatio = aspectRatio
    self.cornerRadius = cornerRadius
    self.bordered = bordered
  }

  public var body: some View {
    Rectangle()
      .fill(.fill.tertiary)
      .overlay {
        content()
          .aspectRatio(contentMode: .fill)
      }
      .frame(width: width, height: width / aspectRatio)
      .clipShape(.rect(cornerRadius: cornerRadius))
      .overlay {
        if bordered {
          RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(.fill)
        }
      }
  }
}

public extension MangaCoverImage where Content == Image? {
  init(
    image: Image?,
    width: CGFloat,
    aspectRatio: CGFloat = 0.7,
    cornerRadius: CGFloat = 8,
    bordered: Bool = true
  ) {
    self.init(
      content: { image?.resizable() },
      width: width,
      aspectRatio: aspectRatio,
      cornerRadius: cornerRadius,
      bordered: bordered
    )
  }
}
