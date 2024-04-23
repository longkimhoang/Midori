//
//  LocalizedString.swift
//
//
//  Created by Long Kim on 23/4/24.
//

import Foundation

/// A localized string from the MangaDex API.
///
/// Refer to [MangaDex API](https://api.mangadex.org/docs/3-enumerations/) for explaination
/// on how ``LocalizedString/languageCode`` is used for localization.
public struct LocalizedString: Decodable {
  /// A dictionary whose keys are language code and values are the localized value.
  public let values: [String: String]

  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let values = try container.decode([String: String].self)
    guard !values.isEmpty else {
      throw DecodingError.dataCorrupted(
        .init(codingPath: container.codingPath, debugDescription: "Values cannot be empty")
      )
    }

    self.values = values
  }
}
