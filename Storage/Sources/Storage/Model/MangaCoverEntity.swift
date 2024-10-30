//
//  MangaCoverEntity.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Foundation
import SwiftData

@Model
public final class MangaCoverEntity {
    public enum ImageSize: Int, Codable {
        case original
        case smallThumbnail
        case mediumThumbnail
    }

    public var imageURLs: [ImageSize: URL]
    public var volume: String?

    public init(imageURLs: [ImageSize: URL] = [:], volume: String? = nil) {
        self.imageURLs = imageURLs
        self.volume = volume
    }

    @Relationship public var manga: MangaEntity?
}
