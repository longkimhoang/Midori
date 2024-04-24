//
//  Cover.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Foundation
import HelperCoders
import MetaCodable

@Codable
public struct Cover: Entity {
  public struct Attributes: Codable, Sendable {
    public let locale: String
    public let fileName: String
    public let volume: String?
  }

  public let id: UUID
  public let attributes: Attributes
  @CodedBy(SequenceCoder(elementHelper: RelationshipCoder(), configuration: .lossy))
  public let relationships: [any Relationship]

  public init(id: UUID, attributes: Attributes) {
    self.id = id
    self.attributes = attributes
    relationships = []
  }
}
