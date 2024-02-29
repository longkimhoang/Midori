//
//  LocalizedString.swift
//
//
//  Created by Long Kim on 26/02/2024.
//

import Foundation
import MetaCodable

/// A localized string from the MangaDex API.
///
/// Refer to [MangaDex API](https://api.mangadex.org/docs/3-enumerations/) for explaination
/// on how ``LocalizedString/languageCode`` is used for localization.
@Codable
public struct LocalizedString {
  public let languageCode: String
  public let value: String
}

extension LocalizedString: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.init(languageCode: "en", value: value)
  }
}
