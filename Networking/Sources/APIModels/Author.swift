//
//  Author.swift
//
//
//  Created by Long Kim on 04/03/2024.
//

import Common
import Foundation
import MetaCodable

@Codable
@MemberInit
public struct Author {
  public typealias Attributes = AuthorAttributes

  public let id: UUID
  public let attributes: Attributes
}

@Codable
public struct AuthorAttributes {
  public let name: String
  @CodedAt("imageUrl")
  public let imageURL: URL?
  @CodedBy(LocalizedStringCoder())
  public let biography: LocalizedString?
}
