//
//  Manga.swift
//
//
//  Created by Long Kim on 23/4/24.
//

import Foundation
import HelperCoders
import MetaCodable

@Codable
public struct Manga: Entity {
  @Codable
  public struct Attributes: Sendable {
    @CodedBy(LocalizedStringCoder()) public let title: LocalizedString
    @CodedBy(LocalizedStringCoder()) public let description: LocalizedString?
    public let createdAt: Date
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
