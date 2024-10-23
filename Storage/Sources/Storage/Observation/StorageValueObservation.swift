//
//  StorageValueObservation.swift
//  Storage
//
//  Created by Long Kim on 22/10/24.
//

import Combine
import Foundation

public class StorageValuePublisher<Output>: Publisher {
    public typealias Failure = Error

    /// Ensures the first value is delivered on the main actor.
    @MainActor func receivesFirstValueImmediately() -> Self {
        fatalError("Not implemented")
    }

    /// Schedules the delivery of items on the specified queue.
    func schedule(on _: DispatchQueue) -> Self {
        fatalError("Not implemented")
    }

    public func receive<S>(subscriber _: S) where S: Subscriber, S.Input == Output,
        S.Failure == Error
    {
        fatalError("Not implemented")
    }
}
