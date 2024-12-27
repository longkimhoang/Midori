//
//  PersonalAuthClientService+Live.swift
//  Services
//
//  Created by Long Kim on 27/12/24.
//

import Dependencies
import Foundation
import MidoriServices
import Security

extension PersonalAuthClientService: DependencyKey {
    public static let liveValue: Self = PersonalAuthClientService(
        fetchClientConfiguration: {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecReturnData: true,
            ] as CFDictionary

            var item: CFTypeRef?
            let result = SecItemCopyMatching(query, &item)
            guard result == errSecSuccess, let data = item as? Data else {
                return nil
            }

            return try? JSONDecoder().decode(PersonalClientConfiguration.self, from: data)
        },
        saveClientConfiguration: { configuration in
            guard let data = try? JSONEncoder().encode(configuration) else {
                return
            }

            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
            ]

            let update = [
                kSecValueData: data,
            ]

            let attributes = query.merging(update) { $1 }
            let result = SecItemAdd(attributes as CFDictionary, nil)

            if result == errSecDuplicateItem {
                SecItemUpdate(query as CFDictionary, update as CFDictionary)
            }
        }
    )

    static let account = "PersonalAuthClient"
    static let service = "com.longkimhoang.Midori.services.personal-auth-client"
}
