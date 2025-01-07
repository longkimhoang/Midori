//
//  PersonalAuthClientService.swift
//  Services
//
//  Created by Long Kim on 27/12/24.
//

import Dependencies

public struct PersonalClientConfiguration: Codable, Sendable {
    public let clientID: String
    public let clientSecret: String

    public init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
}

public struct PersonalAuthClientService: Sendable {
    public var fetchClientConfiguration: @Sendable () -> PersonalClientConfiguration?
    public var saveClientConfiguration: @Sendable (_ config: PersonalClientConfiguration) -> Void

    public init(
        fetchClientConfiguration: @escaping @Sendable () -> PersonalClientConfiguration?,
        saveClientConfiguration: @escaping @Sendable (_ config: PersonalClientConfiguration) -> Void
    ) {
        self.fetchClientConfiguration = fetchClientConfiguration
        self.saveClientConfiguration = saveClientConfiguration
    }
}

extension PersonalAuthClientService: TestDependencyKey {
    public static func inMemory(storage: LockIsolated<PersonalClientConfiguration?>) -> Self {
        PersonalAuthClientService(
            fetchClientConfiguration: { storage.value },
            saveClientConfiguration: { storage.setValue($0) }
        )
    }

    public static let testValue: PersonalAuthClientService = .inMemory(storage: .init(nil))
}

extension DependencyValues {
    public var personalAuthClientService: PersonalAuthClientService {
        get { self[PersonalAuthClientService.self] }
        set { self[PersonalAuthClientService.self] = newValue }
    }
}
