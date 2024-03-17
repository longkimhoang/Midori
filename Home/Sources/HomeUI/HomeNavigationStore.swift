//
//  HomeNavigationStore.swift
//
//
//  Created by Long Kim on 16/3/24.
//

import Database
import Foundation
import SwiftUI

enum HomeNavigationDestination: Hashable, Codable {
  case latestUpdates
  case recentlyAdded
  case manga(Manga.ID)
}

final class HomeNavigationStore: ObservableObject, Codable {
  typealias Destination = HomeNavigationDestination

  @Published var path: [Destination] = []

  init() {}

  func restore(from serializedData: Data) {
    guard let store = try? JSONDecoder().decode(HomeNavigationStore.self, from: serializedData)
    else {
      return
    }

    path = store.path
  }

  var serialziedData: Data? {
    try? JSONEncoder().encode(self)
  }

  // MARK: Codable support

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(path, forKey: .path)
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    path = try container.decode([Destination].self, forKey: .path)
  }

  private enum CodingKeys: String, CodingKey {
    case path
  }
}
