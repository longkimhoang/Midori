//
//  LocalizedString.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Foundation
import NonEmpty

/// A string value with localized variants.
public struct LocalizedString: Codable {
  var values: NonEmptyDictionary<String, String>

  public init(values: NonEmptyDictionary<String, String>) {
    self.values = values
  }
}

public extension LocalizedString {
  /// Gets the localized variant with the specified `languageCode`.
  ///
  /// This method returns the default variant if the specified variant was not found.
  subscript(languageCode code: String) -> String {
    values[code] ?? values.first.value
  }
}

extension LocalizedString: LosslessStringConvertible {
  public init?(_ description: String) {
    self.init(values: ["en": description])
  }

  public var description: String {
    values.first.value
  }
}
