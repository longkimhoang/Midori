//
//  AppDestination.swift
//  Midori
//
//  Created by Long Kim on 17/3/24.
//

import Foundation
import SwiftUI

enum AppDestination: Int, Hashable, CaseIterable {
  case home
}

extension AppDestination {
  var localizedTitle: LocalizedStringKey {
    switch self {
    case .home: "Home"
    }
  }
}
