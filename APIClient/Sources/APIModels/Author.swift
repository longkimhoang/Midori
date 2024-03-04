//
//  Author.swift
//
//
//  Created by Long Kim on 04/03/2024.
//

import APICommon
import Foundation
import MetaCodable

@Codable
public struct Author {
  public let id: UUID

  @CodedIn("attributes")
  public let name: String

  @CodedAt("attributes", "imageUrl")
  public let imageURL: URL?

  @CodedIn("attributes")
  @CodedBy(LocalizedStringCoder())
  public let biography: LocalizedString?
}
