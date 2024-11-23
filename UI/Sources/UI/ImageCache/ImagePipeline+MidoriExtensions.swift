//
//  ImagePipeline+MidoriExtensions.swift
//  UI
//
//  Created by Long Kim on 30/10/24.
//

import Nuke

extension ImagePipeline {
    /// Shared pipeline for the app.
    static let midoriApp: ImagePipeline = ImagePipeline {
        $0.isUsingPrepareForDisplay = true
    }

    /// Pipeline used for the reader.
    ///
    /// Data should be cached locally on disk without relying on `URLCache`,
    /// as MangaDex CDNs are ephemeral. Also handles CDN quality reporting to help the system route
    /// the best CDN to us (and other users, let's all be civilized API user)
    static let midoriReader: ImagePipeline = {
        var configuration = ImagePipeline.Configuration.withDataCache(
            name: "MidoriReader",
            sizeLimit: 512 * 1024 * 1024 // 512 MB
        )
        configuration.isUsingPrepareForDisplay = true

        return ImagePipeline(configuration: configuration)
    }()
}
