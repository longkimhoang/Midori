//
//  LocalizedStringCoder.swift
//
//
//  Created by Long Kim on 26/02/2024.
//

import MetaCodable

package struct LocalizedStringCoder: HelperCoder {

  package init() {}

  package func decode(from decoder: Decoder) throws -> LocalizedString {
    let container = try decoder.singleValueContainer()
    let dict = try container.decode([String: String].self)
    guard let entry = dict.first else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Expected to find an object of 1 languageCode-value pair"
        )
      )
    }

    let (code, value) = entry
    return LocalizedString(languageCode: code, value: value)
  }

  package func decodeIfPresent<DecodingContainer>(
    from container: DecodingContainer, forKey key: DecodingContainer.Key
  ) throws -> LocalizedString? where DecodingContainer: KeyedDecodingContainerProtocol {
    let dict = try container.decode([String: String].self, forKey: key)
    guard let entry = dict.first else {
      return nil
    }

    let (code, value) = entry
    return LocalizedString(languageCode: code, value: value)
  }
}
