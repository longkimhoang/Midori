//
//  HomeDataModel.swift
//
//
//  Created by Long Kim on 16/3/24.
//

import Database
import Dependencies
import Foundation
import IdentifiedCollections

@MainActor
public final class HomeDataModel: ObservableObject {
  @Dependency(\.popularMangas) var popularMangas
  @Dependency(\.latestChapters) var latestChapters
  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

  @Published public var fetchStatus: HomeDataFetchStatus = .loading

  public init() {}

  public func fetch() async {
    do {
      async let popularMangas = try await popularMangas.fetch()
      async let latestChapters = try await latestChapters.fetch()
      async let recentlyAddedMangas = try await recentlyAddedMangas.fetch()

      let data = try await HomeData(
        popularMangas: IdentifiedArray(uniqueElements: popularMangas),
        latestChapters: IdentifiedArray(uniqueElements: latestChapters),
        recentlyAddedMangas: IdentifiedArray(uniqueElements: recentlyAddedMangas)
      )

      fetchStatus = .success(data)
    } catch {
      fetchStatus = .failure(error)
    }
  }

  public func restore(from serializedData: Data) throws {
    guard let representation = try? JSONDecoder().decode(
      CodableRepresentation.self,
      from: serializedData
    ) else {
      return
    }

    let popularMangas = try popularMangas.restore(ids: representation.popular)
    let latestChapters = try latestChapters.restore(ids: representation.latest)
    let recentlyAddedMangas = try recentlyAddedMangas.restore(ids: representation.recent)

    let data = HomeData(
      popularMangas: IdentifiedArray(uniqueElements: popularMangas),
      latestChapters: IdentifiedArray(uniqueElements: latestChapters),
      recentlyAddedMangas: IdentifiedArray(uniqueElements: recentlyAddedMangas)
    )
    fetchStatus = .success(data)
  }

  public var serializedData: Data? {
    guard let data = fetchStatus.success else { return nil }

    let respresentation = CodableRepresentation(
      popular: data.popularMangas.ids.elements,
      latest: data.latestChapters.ids.elements,
      recent: data.recentlyAddedMangas.ids.elements
    )

    return try? JSONEncoder().encode(respresentation)
  }
}

private struct CodableRepresentation: Codable {
  let popular: [Manga.ID]
  let latest: [Chapter.ID]
  let recent: [Manga.ID]
}
