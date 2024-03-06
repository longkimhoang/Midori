//
//  ListChapters.swift
//
//
//  Created by Long Kim on 06/03/2024.
//

import APIModels
import Foundation
import MetaCodable

@Codable
public struct ListChapters {
  public let limit: Int
  public let offset: Int
  public let total: Int
  @CodedAt("data") public let chapters: [Chapter]
}
