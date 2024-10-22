//
//  StorageValuePublisher+Testing.swift
//  Storage
//
//  Created by Long Kim on 22/10/24.
//

@preconcurrency import Combine
import ConcurrencyExtras
import Foundation
import XCTestDynamicOverlay

/// A StorageValuePublisher that doesn't emit any values.
struct EmptyStorageValuePublisher<Value: Sendable>: StorageValuePublisher {
    public typealias Output = Value

    @MainActor public func receivesFirstValueImmediately() -> Self {
        self
    }

    public func schedule(on _: DispatchQueue) -> Self {
        self
    }

    public func receive<S>(subscriber: S) where S: Subscriber, S.Input == Value,
        S.Failure == Error
    {
        Empty().receive(subscriber: subscriber)
    }
}

/// A StorageValuePublisher that publishes a single value then completes.
final class StaticStorageValuePublisher<Value: Sendable>: StorageValuePublisher {
    public typealias Output = Value

    private let value: Value
    private let queue: LockIsolated<DispatchQueue> = LockIsolated(.global())

    init(_ value: Value) {
        self.value = value
    }

    @MainActor func receivesFirstValueImmediately() -> Self {
        queue.setValue(.main)
        return self
    }

    func schedule(on queue: DispatchQueue) -> Self {
        self.queue.setValue(queue)
        return self
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Input == Value, S.Failure == Error {
        let inner = queue.withValue { queue in
            Just(value).setFailureType(to: Error.self).receive(on: queue)
        }

        inner.subscribe(subscriber)
    }
}

/// A StorageValuePublisher that completes with the specified error.
final class FailingStorageValuePublisher<Value: Sendable>: StorageValuePublisher {
    public typealias Output = Value

    private let failure: Error
    private let queue: LockIsolated<DispatchQueue> = LockIsolated(.global())

    init(_ failure: Error) {
        self.failure = failure
    }

    @MainActor func receivesFirstValueImmediately() -> Self {
        queue.setValue(.main)
        return self
    }

    func schedule(on queue: DispatchQueue) -> Self {
        self.queue.setValue(queue)
        return self
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Input == Value, S.Failure == Error {
        let inner = queue.withValue { queue in
            Fail(outputType: Value.self, failure: failure).receive(on: queue)
        }

        inner.subscribe(subscriber)
    }
}
