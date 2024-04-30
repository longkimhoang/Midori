//
//  Cover.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Foundation

public struct Cover: Entity {
  public struct Attributes: Decodable, Sendable {
    public let locale: String
    public let fileName: String
    public let volume: String?
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
