//
//  ScanlationGroup.swift
//
//
//  Created by Long Kim on 2/5/24.
//

import Foundation
import SwiftData

@Model
public final class ScanlationGroup {
  @Attribute(.unique) public var groupID: UUID
  public var name: String
  public var groupDescription: String?

  public init(
    groupID: UUID,
    name: String,
    groupDescription: String? = nil
  ) {
    self.groupID = groupID
    self.name = name
    self.groupDescription = groupDescription
  }

  // MARK: - Relationships

  @Relationship(inverse: \Chapter.scanlationGroup) public var chapters: [Chapter] = []
}
