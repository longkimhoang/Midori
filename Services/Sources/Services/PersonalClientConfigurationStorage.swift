//
//  PersonalClientConfigurationStorage.swift
//  Services
//
//  Created by Long Kim on 27/12/24.
//

import Dependencies
import MangaDexAuth

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

extension PersonalClientConfigurationStorage: TestDependencyKey {
    public static func inMemory(value: LockIsolated<PersonalClientConfiguration?>) -> Self {
        PersonalClientConfigurationStorage(
            load: { _ in value.value },
            save: { value.setValue($0) }
        )
    }

    public static var testValue: Self {
        inMemory(value: .init(nil))
    }
}

public extension DependencyValues {
    var personalClientConfigurationStorage: PersonalClientConfigurationStorage {
        get { self[PersonalClientConfigurationStorage.self] }
        set { self[PersonalClientConfigurationStorage.self] = newValue }
    }
}
