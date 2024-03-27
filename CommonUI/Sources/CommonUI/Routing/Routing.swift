//
//  Routing.swift
//
//
//  Created by Long Kim on 27/3/24.
//

import Foundation

@MainActor
public protocol Routing: AnyObject {
  typealias Context = RouterContext

  var parent: (any Routing)? { get }
  var children: [any Routing] { get }

  func start(context: Context)
  func updateStateRestorationActivity()
}

public extension Routing {
  var parent: (any Routing)? { nil }
  var children: [any Routing] { [] }
}

public struct RouterContext {
  public let restorationActivity: NSUserActivity?
}
