//
//  CellRegistration+AsyncImageLoading.swift
//
//
//  Created by Long Kim on 15/3/24.
//

import Foundation
import Nuke
import UIKit

public extension UICollectionView.CellRegistration {
  typealias ConfigurationHandler = (Cell, IndexPath, Item, UIImage?) -> Void
  typealias ImageLoadSuccessHandler = (IndexPath, ImageResponse) -> Void

  init(
    url: @escaping (Item) -> URL?,
    handler: @escaping ConfigurationHandler,
    onLoadSuccess: @escaping ImageLoadSuccessHandler
  ) {
    let imagePipeline = ImagePipeline.shared
    self.init { cell, indexPath, item in
      let request = ImageRequest(url: url(item))
      let image = imagePipeline.cache.cachedImage(for: request).map(\.image)

      if let image {
        handler(cell, indexPath, item, image)
      } else {
        handler(cell, indexPath, item, nil)
        // Load image and reconfigure the cell
        imagePipeline.loadImage(with: request) { result in
          switch result {
          case let .success(response):
            onLoadSuccess(indexPath, response)
          case .failure:
            break
          }
        }
      }
    }
  }
}
