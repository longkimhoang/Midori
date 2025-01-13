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

        // Most chapters have at most around 20-30 pages, so we can limit the amount of images cached in memory,
        // as users are unlikely to jump back to a previous chapter. And if they do, we can serve from disk cache.
        let memoryCache = ImageCache(countLimit: 30)
        configuration.imageCache = memoryCache

        // Make sure MangaDex@Home servers don't die. They are self hosted CDNs, not Cloudflare :)
        configuration.dataLoadingQueue.maxConcurrentOperationCount = 3

        return ImagePipeline(configuration: configuration)
    }()
}
