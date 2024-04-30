//
//  LocalizedString.swift
//
//
//  Created by Long Kim on 23/4/24.
//

import Foundation
import NonEmpty

/// A localized string from the MangaDex API.
///
/// Refer to [MangaDex API](https://api.mangadex.org/docs/3-enumerations/) for explaination
/// on how ``LocalizedString/languageCode`` is used for localization.
public struct LocalizedString: Decodable, Sendable {
  public let values: NonEmptyDictionary<String, String>

  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    values = try container.decode(NonEmptyDictionary<String, String>.self)
  }
}

/// A property wrapper that handles `nil` and empty ``LocalizedString-15sh1`` instances.
@propertyWrapper
public struct NullableLocalizedString: Decodable, Sendable {
  public let wrappedValue: LocalizedString?

  public init(wrappedValue: LocalizedString? = nil) {
    self.wrappedValue = wrappedValue
  }

  public init(from decoder: any Decoder) throws {
    do {
      let container = try decoder.singleValueContainer()
      wrappedValue = try container.decode(LocalizedString.self)
    } catch {
      wrappedValue = nil
    }
  }
}
