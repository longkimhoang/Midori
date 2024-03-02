//
//  Reference.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import Foundation
import MetaCodable

public enum ReferenceType: String, Codable {
  case cover = "cover_art"
}

/// Models MangaDex API's reference expansion mechanism.
@Codable
@CodedAt("type")
public enum Reference {
  @CodedAs("cover_art")
  case cover(Cover)
}
