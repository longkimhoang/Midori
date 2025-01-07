//
//  Manga.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation

public struct Manga: Entity {
    public struct Attributes: Decodable, Sendable {
        public let title: LocalizedString
        public let altTitles: [LocalizedString]
        @LossyDecodable public var description: LocalizedString?
        public let createdAt: Date
    }

    public let id: UUID
    public let attributes: Attributes
    public let relationships: RelationshipContainer

    public init(id: UUID, attributes: Attributes) {
        self.id = id
        self.attributes = attributes
        relationships = RelationshipContainer()
    }
}

// MARK: - Retrieving cover image URL

extension Manga {
    public enum ImageSize: CaseIterable {
        case original, small, medium
    }

    public func coverImageURL(with fileName: String, size: ImageSize) -> URL {
        let baseURL = URL(string: "https://uploads.mangadex.org/covers")!.appending(path: id.uuidString.lowercased())

        let fileName =
            switch size {
            case .original:
                fileName
            case .small:
                "\(fileName).256.jpg"
            case .medium:
                "\(fileName).512.jpg"
            }

        return baseURL.appending(component: fileName)
    }
}
