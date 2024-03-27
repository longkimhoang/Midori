//
//  Routing.swift
//  Midori
//
//  Created by Long Kim on 27/3/24.
//

import UIKit

@MainActor
protocol Routing: AnyObject {
  typealias Context = RouterContext

  var parent: (any Routing)? { get }
  var children: [any Routing] { get }
}

extension Routing {
  var parent: (any Routing)? {
    nil
  }

  var children: [any Routing] {
    []
  }
}

struct RouterContext {
  let restorationActivity: NSUserActivity?
}
