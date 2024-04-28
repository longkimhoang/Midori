//
//  Author.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import Foundation
import HelperCoders
import MetaCodable

@Codable
public struct Author: Entity {
  @Codable
  public struct Attributes: Sendable {
    public let name: String
    @CodedAt("imageUrl") public let imageURL: URL?
    @CodedBy(LocalizedStringCoder()) public let biography: LocalizedString?
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
