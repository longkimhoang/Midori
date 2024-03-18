//
//  CellRegistration+AsyncImageLoading.swift
//
//
//  Created by Long Kim on 15/3/24.
//

import Foundation
import Nuke

#if canImport(UIKit)
import UIKit
#endif

#if os(macOS)
import AdvancedCollectionTableView
import AppKit
#endif

#if os(iOS)
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

      handler(cell, indexPath, item, image)

      if image == nil {
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
#else
public extension NSCollectionView.ItemRegistration {
  typealias ConfigurationHandler = (Item, IndexPath, Element, NSImage?) -> Void
  typealias ImageLoadSuccessHandler = (IndexPath, ImageResponse) -> Void

  init(
    url: @escaping (Element) -> URL?,
    handler: @escaping ConfigurationHandler,
    onLoadSuccess: @escaping ImageLoadSuccessHandler
  ) {
    let imagePipeline = ImagePipeline.shared
    self.init { cell, indexPath, item in
      let request = ImageRequest(url: url(item))
      let image = imagePipeline.cache.cachedImage(for: request).map(\.image)

      handler(cell, indexPath, item, image)

      if image == nil {
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
#endif
