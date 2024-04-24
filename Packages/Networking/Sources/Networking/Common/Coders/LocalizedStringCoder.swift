//
//  LocalizedStringCoder.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import MetaCodable
import NonEmpty

struct LocalizedStringCoder: HelperCoder {
  func decode(from decoder: any Decoder) throws -> LocalizedString {
    let container = try decoder.singleValueContainer()
    let values = try container.decode(NonEmpty<[String: String]>.self)
    return LocalizedString(values: values)
  }

  func decodeIfPresent<DecodingContainer: KeyedDecodingContainerProtocol>(
    from container: DecodingContainer,
    forKey key: DecodingContainer.Key
  ) throws -> LocalizedString? {
    guard let isNil = try? container.decodeNil(forKey: key), !isNil
    else { return nil }
    do {
      return try decode(from: container, forKey: key)
    } catch {
      return nil
    }
  }
}
