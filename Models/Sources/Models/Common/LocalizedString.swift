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
public struct LocalizedString: Equatable, Sendable, CustomDebugStringConvertible {
    public struct DefaultVariant: Equatable, Sendable {
        public let languageCode: LanguageCode
        public let value: String

        public init(languageCode: LanguageCode, value: String) {
            self.languageCode = languageCode
            self.value = value
        }
    }

    /// The language code
    public typealias LanguageCode = Tagged<LocalizedString, String>

    /// The default variant.
    public let defaultVariant: DefaultVariant

    /// Other localized variants. Can be empty.
    public let localizedVariants: [LanguageCode: String]

    public init(
        defaultVariant: DefaultVariant,
        localizedVariants: [LanguageCode: String] = [:]
    ) {
        self.defaultVariant = defaultVariant
        self.localizedVariants = localizedVariants
    }

    public var debugDescription: String {
        """
        LocalizedString {
            defaultVariant = { code=\(defaultVariant.languageCode), value=\(defaultVariant.value) }
            localizedVariants = \(localizedVariants.debugDescription)
        }
        """
    }
}

public extension LocalizedString {
    init?(_ dictionary: [LanguageCode: String]) {
        guard let (key, value) = dictionary.first else {
            return nil
        }

        let defaultVariant = DefaultVariant(languageCode: key, value: value)
        let localizedVariants = dictionary.dropFirst().reduce(into: [:]) { result, pair in
            result[pair.key] = pair.value
        }

        self.init(defaultVariant: defaultVariant, localizedVariants: localizedVariants)
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
        localizedVariants[language] ?? defaultVariant.value
    }

    /// Returns the value for the given locale, or the value for the default variant if not found.
    subscript(locale: Locale) -> String {
        let language = LanguageCode(rawValue: locale.identifier)
        return self[language]
    }
}
