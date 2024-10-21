//
//  LocalizedString.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

/// A localized string from the MangaDex API.
public struct LocalizedString: Decodable, Sendable {
    // Typealias for a languageCode-string pair
    typealias Variant = (String, String)

    // A lot of localized strings only have 1 variant, so a dictionary is overkill
    enum Storage {
        case single(Variant)
        case multiple(Variant, [String: String]) // a primary variant and other variants, if any
    }

    let storage: Storage

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        var localizedVariants = try container.decode([String: String].self)
        guard let (key, value) = localizedVariants.first else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "must contain at least 1 variant"
            )
        }

        if localizedVariants.count == 1 {
            storage = .single((key, value))
        } else {
            localizedVariants[key] = nil
            storage = .multiple((key, value), localizedVariants)
        }
    }

    /// The default value. Usually English.
    public var defaultVariant: String {
        switch storage {
        case .single(let (_, value)): value
        case let .multiple((_, defaultVariant), _): defaultVariant
        }
    }

    /// Other localized variants. Can be empty.
    public var localizedVariants: [String: String] {
        switch storage {
        case .single: [:]
        case let .multiple(_, localizedVariants): localizedVariants
        }
    }
}
