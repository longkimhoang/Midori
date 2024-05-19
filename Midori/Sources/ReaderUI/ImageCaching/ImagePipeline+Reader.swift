//
//  ImagePipeline+Reader.swift
//
//
//  Created by Long Kim on 16/5/24.
//

import Nuke

extension ImagePipeline {
  /// The `ImagePipeline` instance for downloading and caching chapter pages.
  static let reader: ImagePipeline = {
    let sizeLimit = 1024 * 1024 * 300 // 300 MB
    var configuration = ImagePipeline.Configuration.withDataCache(sizeLimit: sizeLimit)
    configuration.isProgressiveDecodingEnabled = true

    return ImagePipeline(configuration: configuration)
  }()
}
