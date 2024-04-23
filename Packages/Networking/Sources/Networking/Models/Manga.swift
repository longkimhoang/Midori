//
//  Manga.swift
//
//
//  Created by Long Kim on 23/4/24.
//

import Foundation

public struct Manga: Decodable {
  public struct Attributes: Decodable {
    public let title: LocalizedString
    public let description: LocalizedString?
    public let createdAt: Date

    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      title = try container.decode(LocalizedString.self, forKey: .title)
      do {
        description = try container.decodeIfPresent(LocalizedString.self, forKey: .description)
      } catch {
        description = nil
      }
      createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    enum CodingKeys: CodingKey {
      case title
      case description
      case createdAt
    }
  }

  public let id: UUID
  public let attributes: Attributes
}
