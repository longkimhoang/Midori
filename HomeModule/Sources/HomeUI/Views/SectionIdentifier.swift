//
//  SectionIdentifier.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import Foundation

enum SectionIdentifier: Int, CaseIterable, Identifiable {
  case popular
  case latestUpdates
  case recentlyAdded

  var id: Self { self }
}
