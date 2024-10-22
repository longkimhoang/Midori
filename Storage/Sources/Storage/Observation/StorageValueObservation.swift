//
//  StorageValueObservation.swift
//  Storage
//
//  Created by Long Kim on 22/10/24.
//

import Combine
import Dependencies
import Foundation
import GRDB

public protocol StorageValuePublisher<Output>: Publisher, Sendable where Output: Sendable {
    associatedtype Failure = Error

    /// Ensures the first value is delivered on the main actor.
    @MainActor func receivesFirstValueImmediately() -> Self

    /// Schedules the delivery of items on the specified queue.
    func schedule(on queue: DispatchQueue) -> Self
}

// MARK: - GRDB Implementation

struct GRDBStorageValuePublisher<Value: Sendable>: StorageValuePublisher {
    typealias Output = Value

    @Dependency(\.persistenceContainer.dbReader) private var dbReader
    private let scheduler: ValueObservationScheduler
    private let operation: @Sendable (Database) -> Value

    init(
        scheduler: ValueObservationScheduler = .async(onQueue: .global()),
        observing operation: @escaping @Sendable (Database) -> Value
    ) {
        self.scheduler = scheduler
        self.operation = operation
    }

    @MainActor func receivesFirstValueImmediately() -> Self {
        Self(scheduler: .immediate, observing: operation)
    }

    func schedule(on queue: DispatchQueue) -> Self {
        Self(scheduler: .async(onQueue: queue), observing: operation)
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Input == Value, S.Failure == Error {
        let implementation = ValueObservation.tracking(operation).publisher(
            in: dbReader,
            scheduling: scheduler
        )
        implementation.subscribe(subscriber)
    }
}
