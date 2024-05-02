//
//  ScanlationGroup.swift
//
//
//  Created by Long Kim on 2/5/24.
//

import Foundation

public struct ScanlationGroup: Entity {
  public struct Attributes: Decodable, Sendable {
    public let name: String
    public let description: String?
  }

  public let id: UUID
  public let attributes: Attributes

  public init(id: UUID, attributes: Attributes) {
    self.id = id
    self.attributes = attributes
  }
}
