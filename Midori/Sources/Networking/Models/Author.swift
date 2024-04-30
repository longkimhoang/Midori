//
//  Author.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import Foundation

public struct Author: Entity {
  public struct Attributes: Decodable, Sendable {
    public let name: String
    public let imageURL: URL?
    @NullableLocalizedString public var biography
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
