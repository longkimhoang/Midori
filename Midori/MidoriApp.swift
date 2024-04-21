//
//  MidoriApp.swift
//  Midori
//
//  Created by Long Kim on 21/4/24.
//

import Application
import ApplicationUI
import ComposableArchitecture
import SwiftUI

@main
struct MidoriApp: App {
  var body: some Scene {
    WindowGroup {
      let store = Store(initialState: ApplicationFeature.State()) {
        ApplicationFeature()
      }

      ApplicationView(store: store)
    }
  }
}
