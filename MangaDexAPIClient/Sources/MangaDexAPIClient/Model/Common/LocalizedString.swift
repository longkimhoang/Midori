//
//  LocalizedString.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

/// A localized string from the MangaDex API.
public struct LocalizedString: Decodable, Sendable {
    /// The default value. Usually English.
    public let defaultVariant: String
    /// Other localized variants. Can be empty.
    public let localizedVariants: [String: String]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        var localizedVariants = try container.decode([String: String].self)
        guard let (key, value) = localizedVariants.first else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "must contain at least 1 variant"
            )
        }

        defaultVariant = localizedVariants["en"] ?? value
        localizedVariants[key] = nil
        self.localizedVariants = localizedVariants
    }
}
