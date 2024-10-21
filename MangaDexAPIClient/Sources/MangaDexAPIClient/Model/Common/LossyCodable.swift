//
//  LossyCodable.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

/// A property wrapper that defaults an Optional decodable value to `nil` if decoding fails.
@propertyWrapper
public struct LossyDecodable<Wrapped: Decodable>: Decodable {
    public let wrappedValue: Wrapped?

    public init(wrappedValue: Wrapped? = nil) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: any Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            wrappedValue = try container.decode(Wrapped.self)
        } catch {
            wrappedValue = nil
        }
    }
}

extension LossyDecodable: Sendable where Wrapped: Sendable {}
extension LossyDecodable: Equatable where Wrapped: Equatable {}
