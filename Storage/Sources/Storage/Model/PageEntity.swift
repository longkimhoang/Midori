//
//  PageEntity.swift
//  Storage
//
//  Created by Long Kim on 11/11/24.
//

import Foundation
import SwiftData

@Model
public final class PageEntity {
    public enum Quality: Int, Codable {
        case normal
        case dataSaver
    }

    #Unique<PageEntity>([\.chapter, \.pageIndex, \.qualityRepresentation])
    #Index<PageEntity>([\.chapter, \.pageIndex, \.qualityRepresentation])

    // The actual quality stored in the persistent storage, so that SwiftData can apply
    // uniqueness checks and performs indexing.
    var qualityRepresentation: Int

    public var pageIndex: Int
    public var imageURL: URL
    public var quality: Quality {
        get { Quality(rawValue: qualityRepresentation) ?? .normal }
        set { qualityRepresentation = newValue.rawValue }
    }

    public init(pageIndex: Int, quality: Quality, imageURL: URL) {
        self.pageIndex = pageIndex
        qualityRepresentation = quality.rawValue
        self.imageURL = imageURL
    }

    @Relationship public var chapter: ChapterEntity?
}
