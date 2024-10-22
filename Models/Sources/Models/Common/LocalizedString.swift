//
//  LocalizedString.swift
//  Models
//
//  Created by Long Kim on 22/10/24.
//

import Foundation
import Tagged

/// A string with localized variants.
///
/// A localized string contains at least one variant (called the default variant) and optionally
/// includes other variants.
/// At runtime, consumers can decide which variant to use by using the ``subscript(language:)``
/// function.
@DebugDescription
public struct LocalizedString: Sendable, CustomDebugStringConvertible {
    /// The language code
    public typealias LanguageCode = Tagged<LocalizedString, String>

    /// The default value. Usually English.
    public let defaultVariant: (LanguageCode, String)

    /// Other localized variants. Can be empty.
    public let localizedVariants: [LanguageCode: String]

    public init(
        defaultVariant: (LanguageCode, String),
        localizedVariants: [LanguageCode: String] = [:]
    ) {
        self.defaultVariant = defaultVariant
        self.localizedVariants = localizedVariants
    }

    public var debugDescription: String {
        """
        LocalizedString {
            default = \(defaultVariant),
            otherVariants = \(localizedVariants.debugDescription)
        }
        """
    }
}

extension LocalizedString: CustomStringConvertible {
    public var description: String {
        "LocalizedString(default=\(defaultVariant), \(localizedVariants.count) other variants)"
    }
}

extension LocalizedString: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(defaultVariant: ("en", value))
    }
}

// MARK: - Getting the localized value

public extension LocalizedString {
    /// Returns whether the localized string contains the language specified.
    func contains(language: LanguageCode) -> Bool {
        let (defaultLanguage, defaultValue) = defaultVariant
        if defaultLanguage == language {
            return true
        }

        return localizedVariants.keys.contains(language)
    }

    /// Returns the value for the given language, or the value for the default variant if not found.
    subscript(language: LanguageCode) -> String {
        let (defaultLanguage, defaultValue) = defaultVariant
        if defaultLanguage == language {
            return defaultValue
        }

        return localizedVariants[language] ?? defaultValue
    }

    /// Returns the value for the given locale, or the value for the default variant if not found.
    subscript(locale: Locale) -> String {
        let language = LanguageCode(rawValue: locale.identifier)
        return self[language]
    }
}
