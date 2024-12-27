//
//  PersonalClientConfigurationStorage+Live.swift
//  Services
//
//  Created by Long Kim on 27/12/24.
//

import Dependencies
import Foundation
import MangaDexAuth
import MidoriServices
import Security

extension PersonalClientConfigurationStorage: DependencyKey {
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

    public static let liveValue = PersonalClientConfigurationStorage.keychain(
        service: "com.longkimhoang.Midori.Auth.PersonalClientConfigurationStorage"
    )
}
