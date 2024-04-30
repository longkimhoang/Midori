//
//  ImagePipeline+Shared.swift
//
//
//  Created by Long Kim on 27/4/24.
//

import Nuke

public extension ImagePipeline {
  /// The `ImagePipeline` instance used throughout the application.
  static let `default`: ImagePipeline = {
    var configuration = ImagePipeline.Configuration.withURLCache
    configuration.isUsingPrepareForDisplay = true

    return ImagePipeline(configuration: configuration)
  }()
}
