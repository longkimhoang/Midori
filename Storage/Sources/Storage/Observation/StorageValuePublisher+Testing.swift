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
final class EmptyStorageValuePublisher<Value: Sendable>: StorageValuePublisher<Value> {
    typealias Output = Value

    @MainActor override func receivesFirstValueImmediately() -> Self {
        self
    }

    override func schedule(on _: DispatchQueue) -> Self {
        self
    }

    override func receive<S>(subscriber: S) where S: Subscriber, S.Input == Value,
        S.Failure == Error
    {
        Empty().receive(subscriber: subscriber)
    }
}

/// A StorageValuePublisher that publishes a single value then completes.
final class StaticStorageValuePublisher<Value: Sendable>: StorageValuePublisher<Value> {
    public typealias Output = Value

    private let value: Value
    private var queue: DispatchQueue = .global()

    init(_ value: Value) {
        self.value = value
    }

    @MainActor override func receivesFirstValueImmediately() -> Self {
        queue = .main
        return self
    }

    override func schedule(on queue: DispatchQueue) -> Self {
        self.queue = queue
        return self
    }

    override func receive<S>(subscriber: S) where S: Subscriber, S.Input == Value,
        S.Failure == Error
    {
        let inner = Just(value).setFailureType(to: Error.self).receive(on: queue)
        inner.subscribe(subscriber)
    }
}

/// A StorageValuePublisher that completes with the specified error.
final class FailingStorageValuePublisher<Value: Sendable>: StorageValuePublisher<Value> {
    public typealias Output = Value

    private let failure: Error
    private var queue: DispatchQueue = .global()

    init(_ failure: Error) {
        self.failure = failure
    }

    @MainActor override func receivesFirstValueImmediately() -> Self {
        queue = .main
        return self
    }

    override func schedule(on queue: DispatchQueue) -> Self {
        self.queue = queue
        return self
    }

    override func receive<S>(subscriber: S) where S: Subscriber, S.Input == Value,
        S.Failure == Error
    {
        let inner = Fail(outputType: Value.self, failure: failure).receive(on: queue)
        inner.subscribe(subscriber)
    }
}
