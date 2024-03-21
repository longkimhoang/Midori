//
//  StateRestorable.swift
//
//
//  Created by Long Kim on 21/3/24.
//

import Dependencies
import DependenciesMacros
import UIKit

@MainActor
public protocol StateRestorable {
  func updateStateRestorationActivity()
  func restoreState(from activity: NSUserActivity?)
}

@MainActor
public protocol StateRestorationActivityTypeProviding {
  static var activityType: String { get }
}

public extension StateRestorable {
  func updateStateRestorationActivity() {
    // Empty
  }

  func restoreState(from _: NSUserActivity?) {
    // Empty
  }
}
