//
//  Manga.swift
//
//
//  Created by Long Kim on 23/4/24.
//

import Foundation

public struct Manga: Entity {
  public struct Attributes: Decodable, Sendable {
    public let title: LocalizedString
    @NullableLocalizedString public var description
    public let createdAt: Date
  }

  public let id: UUID
  public let attributes: Attributes
  public let relationships: Relationships

  public init(id: UUID, attributes: Attributes) {
    self.id = id
    self.attributes = attributes
    relationships = Relationships()
  }
}
