//
//  LocalizedString.swift
//  Models
//
//  Created by Long Kim on 22/10/24.
//

import Foundation
import NonEmpty

/// A string with localized variants.
///
/// A localized string contains at least one variant (called the default variant) and optionally
/// includes other variants.
/// At runtime, consumers can decide which variant to use by using the ``subscript(language:)``
/// function.
@DebugDescription
public struct LocalizedString: Equatable, Codable, Sendable, CustomDebugStringConvertible {
    /// The localized variants.
    public let localizedVariants: NonEmptyDictionary<LanguageCode, String>

    public init(localizedVariants: NonEmptyDictionary<LanguageCode, String>) {
        self.localizedVariants = localizedVariants
    }

    /// The default variant.
    public var defaultVariant: NonEmptyDictionary<LanguageCode, String>.Element {
        localizedVariants.first
    }

    public var debugDescription: String {
        """
        LocalizedString {
            localizedVariants = \(localizedVariants.debugDescription)
        }
        """
    }
}

// MARK: - Language Code

extension LocalizedString {
    /// The language code.
    public struct LanguageCode: RawRepresentable, Hashable, Sendable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension LocalizedString.LanguageCode {
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
}

extension LocalizedString.LanguageCode: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension LocalizedString.LanguageCode: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - Getting the localized value

extension LocalizedString {
    /// Returns whether the localized string contains the language specified.
    public func contains(language: LanguageCode) -> Bool {
        localizedVariants.keys.contains(language)
    }

    /// Returns the value for the given language, or the value for the default variant if not found.
    public subscript(language: LanguageCode) -> String {
        localizedVariants[language] ?? defaultVariant.value
    }

    /// Returns the value for the given locale, or the value for the default variant if not found.
    public subscript(locale: Locale) -> String {
        let language = LanguageCode(rawValue: locale.identifier)
        return self[language]
    }
}
