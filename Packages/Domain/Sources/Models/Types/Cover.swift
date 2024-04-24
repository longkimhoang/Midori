//
//  Cover.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Foundation

public struct Cover: Codable {
  public let fileName: String
  public let volume: String?

  public init(fileName: String, volume: String? = nil) {
    self.fileName = fileName
    self.volume = volume
  }
}
