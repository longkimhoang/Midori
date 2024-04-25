//
//  LocalizedString.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Dependencies
import Foundation
import NonEmpty

/// A string value with localized variants.
public struct LocalizedString: Equatable, Codable, Sendable {
  var values: NonEmptyDictionary<String, String>

  public init(values: NonEmptyDictionary<String, String>) {
    self.values = values
  }
}

public extension LocalizedString {
  /// Gets the localized variant with the specified `languageCode`.
  ///
  /// This method returns the default variant if the specified variant was not found.
  subscript(languageCode code: Locale.LanguageCode) -> String {
    if let code = code.identifier(.alpha2), let value = values[code] {
      value
    } else {
      values.first.value
    }
  }

  /// Gets the localized variant corresponding to the specified `Locale`.
  func localized(for locale: Locale) -> String {
    let languageCode = locale.language.languageCode ?? .english
    return self[languageCode: languageCode]
  }
}

extension LocalizedString: LosslessStringConvertible {
  public init?(_ description: String) {
    self.init(values: ["en": description])
  }

  public var description: String {
    @Dependency(\.locale.language.languageCode) var languageCode
    return self[languageCode: languageCode ?? .english]
  }
}
