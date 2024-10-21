//
//  RelationshipCoder.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

struct RelationshipCoder {
    func decode(from decoder: any Decoder) throws -> any Relationship {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Kind.self, forKey: .type)
        switch type {
        case .cover:
            return try CoverRelationship(from: decoder)
        case .manga:
            return try MangaRelationship(from: decoder)
        case .author:
            return try AuthorRelationship(from: decoder)
        case .artist:
            return try ArtistRelationship(from: decoder)
        case .scanlationGroup:
            return try ScanlationGroupRelationship(from: decoder)
        }
    }

    enum Kind: String, Decodable {
        case cover = "cover_art"
        case manga
        case author
        case artist
        case scanlationGroup = "scanlation_group"
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
