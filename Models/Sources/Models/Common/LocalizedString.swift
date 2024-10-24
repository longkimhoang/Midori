//
//  LocalizedString.swift
//  Models
//
//  Created by Long Kim on 22/10/24.
//

import Foundation
import NonEmpty
import Tagged

/// A string with localized variants.
///
/// A localized string contains at least one variant (called the default variant) and optionally
/// includes other variants.
/// At runtime, consumers can decide which variant to use by using the ``subscript(language:)``
/// function.
@DebugDescription
public struct LocalizedString: Equatable, Sendable, CustomDebugStringConvertible {
    /// The language code
    public typealias LanguageCode = Tagged<LocalizedString, String>

    /// The localized variants. Can be empty.
    public let localizedVariants: NonEmptyDictionary<LanguageCode, String>

    public init(
        localizedVariants: NonEmptyDictionary<LanguageCode, String>
    ) {
        self.localizedVariants = localizedVariants
    }

    public var debugDescription: String {
        """
        LocalizedString {
            variants = \(localizedVariants.debugDescription)
        }
        """
    }
}

public extension LocalizedString {
    init?(_ dictionary: [String: String]) {
        let localizedVariants: [LanguageCode: String] = dictionary
            .reduce(into: [:]) { result, pair in
                result[LanguageCode(pair.key)] = pair.value
            }

        guard let localizedVariants = NonEmptyDictionary(rawValue: localizedVariants) else {
            return nil
        }

        self.init(localizedVariants: localizedVariants)
    }
}

extension LocalizedString: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(localizedVariants: ["en": value])
    }
}

// MARK: - Getting the localized value

public extension LocalizedString {
    /// Returns whether the localized string contains the language specified.
    func contains(language: LanguageCode) -> Bool {
        localizedVariants.keys.contains(language)
    }

    /// Returns the value for the given language, or the value for the default variant if not found.
    subscript(language: LanguageCode) -> String {
        localizedVariants[language] ?? localizedVariants.first.value
    }

    /// Returns the value for the given locale, or the value for the default variant if not found.
    subscript(locale: Locale) -> String {
        let language = LanguageCode(rawValue: locale.identifier)
        return self[language]
    }
}
