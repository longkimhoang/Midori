//
//  ReaderFeature.swift
//
//
//  Created by Long Kim on 11/5/24.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct ReaderFeature {
  @ObservableState
  public struct State: Equatable, Sendable {}

  public enum Action: Sendable {}

  public init() {}
}
