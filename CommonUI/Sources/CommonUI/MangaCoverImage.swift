//
//  MangaCoverImage.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import SwiftUI

public struct MangaCoverImage: View {
  let image: Image?
  let width: CGFloat
  let aspectRatio: CGFloat
  let cornerRadius: CGFloat
  let bordered: Bool

  public init(
    image: Image?,
    width: CGFloat,
    aspectRatio: CGFloat = 0.7,
    cornerRadius: CGFloat = 8,
    bordered: Bool = true
  ) {
    self.image = image
    self.width = width
    self.aspectRatio = aspectRatio
    self.cornerRadius = cornerRadius
    self.bordered = bordered
  }

  public var body: some View {
    Rectangle()
      .fill(.fill.tertiary)
      .overlay {
        image?
          .resizable()
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
