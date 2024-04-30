//
//  ApplicationScene.swift
//
//
//  Created by Long Kim on 30/4/24.
//

import SwiftUI

/// The main application scene.
public struct ApplicationScene: Scene {
  public init() {}

  public var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }

  struct ContentView: View {
    var body: some View {
      ApplicationView()
    }
  }
}
