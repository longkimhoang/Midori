//
//  RetrieveHomeDataUseCase.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import APIClient
import Foundation

package struct RetrieveHomeDataUseCase {
  package init() {}

  package func execute() async throws -> HomeData {
    async let popularMangas = try await MangaEndpoint.listMangas(parameters: ListMangasParameters(
      createdAtSince: .lastMonth,
      order: ListMangasSortOrder(followedCount: .descending)
    ))

    return try await HomeData(popular: popularMangas.mangas)
  }
}

extension Date {
  fileprivate static var lastMonth: Date? {
    Calendar.current.date(byAdding: .month, value: -1, to: Date(), wrappingComponents: false)
  }
}
