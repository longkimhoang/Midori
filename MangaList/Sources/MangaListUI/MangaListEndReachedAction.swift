//
//  MangaListEndReachedAction.swift
//
//
//  Created by Long Kim on 17/3/24.
//

import SwiftUI

public struct MangaListEndReachedAction {
  let handler: () async -> Void

  public init(handler: @escaping () -> Void) {
    self.handler = handler
  }

  public func callAsFunction() async {
    await handler()
  }
}

extension MangaListEndReachedAction: EnvironmentKey {
  public static var defaultValue: MangaListEndReachedAction {
    MangaListEndReachedAction {}
  }
}

public extension EnvironmentValues {
  var mangaListEndReached: MangaListEndReachedAction {
    get { self[MangaListEndReachedAction.self] }
    set { self[MangaListEndReachedAction.self] = newValue }
  }
}
