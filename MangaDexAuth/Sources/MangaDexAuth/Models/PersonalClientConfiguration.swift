//
//  PersonalClientConfiguration.swift
//  MangaDexAuth
//
//  Created by Long Kim on 27/12/24.
//

import Dependencies
import Foundation
import Security

public struct PersonalClientConfiguration: Sendable {
    public let clientID: String
    public let clientSecret: String

    public init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
}

public struct PersonalClientConfigurationStorage: Sendable {
    public var load: @Sendable (_ clientID: String) -> PersonalClientConfiguration?
    public var save: @Sendable (PersonalClientConfiguration) throws -> Void

    public init(
        load: @escaping @Sendable (_ clientID: String) -> PersonalClientConfiguration?,
        save: @escaping @Sendable (PersonalClientConfiguration) -> Void
    ) {
        self.load = load
        self.save = save
    }
}

public extension PersonalClientConfigurationStorage {
    static func inMemory(value: LockIsolated<PersonalClientConfiguration?>) -> Self {
        PersonalClientConfigurationStorage(
            load: { _ in value.value },
            save: { value.setValue($0) }
        )
    }

    /// A storage backed by the system keychain.
    /// - Parameter service: The service name used for the keychain item entry.
    /// - Returns: The configured storage instance.
    static func keychain(service: String) -> Self {
        PersonalClientConfigurationStorage(
            load: { clientID in
                let query = [
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrAccount: clientID,
                    kSecAttrService: service,
                    kSecReturnData: true,
                ] as CFDictionary

                var item: CFTypeRef?
                let status = SecItemCopyMatching(query, &item)
                guard status == errSecSuccess, let data = item as? Data else {
                    return nil
                }

                return PersonalClientConfiguration(
                    clientID: clientID,
                    clientSecret: String(decoding: data, as: UTF8.self)
                )
            },
            save: { configuration in
                let attributes = [
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrAccount: configuration.clientID,
                    kSecAttrService: service,
                    kSecValueData: Data(configuration.clientSecret.utf8),
                ] as CFDictionary

                let result = SecItemAdd(attributes, nil)
                // if already exists, update the secret
                if result == errSecDuplicateItem {
                    let query = [
                        kSecClass: kSecClassGenericPassword,
                        kSecAttrAccount: configuration.clientID,
                        kSecAttrService: service,
                    ] as CFDictionary

                    let attributesToUpdate = [
                        kSecValueData: Data(configuration.clientSecret.utf8),
                    ] as CFDictionary

                    SecItemUpdate(query, attributesToUpdate)
                }
            }
        )
    }
}

extension PersonalClientConfigurationStorage: TestDependencyKey {
    public static var testValue: Self {
        inMemory(value: .init(nil))
    }
}
