//
//  Cover.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Foundation

public struct Cover: Codable {
  public let id: UUID
  public let fileName: String
  public let volume: String?

  public init(id: UUID, fileName: String, volume: String? = nil) {
    self.id = id
    self.fileName = fileName
    self.volume = volume
  }
}
