//
//  GRDBStorageValuePublisher.swift
//  Storage
//
//  Created by Long Kim on 23/10/24.
//

import Combine
import Dependencies
import Foundation
import GRDB

final class GRDBStorageValuePublisher<
    Output: Sendable,
    Reducer: ValueReducer
>: StorageValuePublisher<Output>
    where Reducer.Value == Output
{
    private let database: DatabaseReader
    private let scheduler: ValueObservationScheduler
    private let observation: ValueObservation<Reducer>

    private init(
        database: DatabaseReader,
        scheduler: ValueObservationScheduler,
        observation: ValueObservation<Reducer>
    ) {
        self.database = database
        self.scheduler = scheduler
        self.observation = observation
    }

    @MainActor override func receivesFirstValueImmediately() -> Self {
        Self(database: database, scheduler: .immediate, observation: observation)
    }

    override func schedule(on queue: DispatchQueue) -> Self {
        Self(database: database, scheduler: .async(onQueue: queue), observation: observation)
    }

    override func receive<S>(subscriber: S) where S: Subscriber, S.Input == Reducer.Value,
        S.Failure == Error
    {
        let implementation = observation.publisher(
            in: database,
            scheduling: scheduler
        )
        implementation.subscribe(subscriber)
    }
}

extension GRDBStorageValuePublisher where Reducer == ValueReducers.Fetch<Output> {
    convenience init(
        scheduler: ValueObservationScheduler = .async(onQueue: .global()),
        operation: @escaping @Sendable (Database) throws -> Output
    ) {
        @Dependency(\.persistenceContainer.dbReader) var dbReader
        self.init(database: dbReader, scheduler: scheduler, observation: .tracking(operation))
    }
}

// MARK: - Operators

extension GRDBStorageValuePublisher {
    func map<Value: Sendable>(
        _ transform: @escaping @Sendable (Output) throws -> Value
    ) -> GRDBStorageValuePublisher<Value, ValueReducers.Map<Reducer, Value>> {
        .init(database: database, scheduler: scheduler, observation: observation.map(transform))
    }
}

extension GRDBStorageValuePublisher where Output: Equatable {
    func removeDuplicates()
        -> GRDBStorageValuePublisher<Output, ValueReducers.RemoveDuplicates<Reducer>>
    {
        .init(database: database, scheduler: scheduler, observation: observation.removeDuplicates())
    }
}
