//
//  HomeData.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import Database
import IdentifiedCollections

struct HomeData {
  let popularMangas: IdentifiedArrayOf<Manga>
  let latestChapters: IdentifiedArrayOf<Chapter>
  let recentlyAddedMangas: IdentifiedArrayOf<Manga>
}
