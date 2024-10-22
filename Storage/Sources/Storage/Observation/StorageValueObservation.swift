//
//  StorageValueObservation.swift
//  Storage
//
//  Created by Long Kim on 22/10/24.
//

import Combine
import Foundation

public protocol StorageValuePublisher<Output>: Publisher, Sendable where Output: Sendable {
    associatedtype Failure = Error

    /// Ensures the first value is delivered on the main actor.
    @MainActor func receivesFirstValueImmediately() -> Self

    /// Schedules the delivery of items on the specified queue.
    func schedule(on queue: DispatchQueue) -> Self
}
