//
//  MangaAPIClient.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import Alamofire
import Dependencies
import DependenciesMacros

@DependencyClient
public struct MangaAPIClient {
  public var listMangas: (_ parameters: ListMangasParameters) async throws -> ListMangas
}

extension MangaAPIClient: DependencyKey {
  public static var liveValue: MangaAPIClient {
    MangaAPIClient(
      listMangas: { parameters in
        try await AF.request(MangaRouter.listMangas(parameters))
          .validate(statusCode: CollectionOfOne(200))
          .serializingDecodable(ListMangas.self)
          .value
      }
    )
  }
}

public extension DependencyValues {
  var mangaAPI: MangaAPIClient {
    get { self[MangaAPIClient.self] }
    set { self[MangaAPIClient.self] = newValue }
  }
}
