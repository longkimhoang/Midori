//
//  MangaAPIClient.swift
//
//
//  Created by Long Kim on 23/4/24.
//

import Alamofire
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct MangaAPIClient: Sendable {
  public var listMangas: @Sendable (_ request: ListMangasRequest) async throws -> ListMangasResponse
  public var mangaFeed: @Sendable (_ request: MangaFeedRequest) async throws -> MangaFeedResponse
  public var getManga: @Sendable (_ request: GetMangaRequest) async throws -> GetMangaResponse
}

extension MangaAPIClient: DependencyKey {
  public static var liveValue: MangaAPIClient {
    let baseURL = URL(string: "https://api.mangadex.org/manga")!
    return MangaAPIClient(
      listMangas: { request in
        let url = baseURL
        let task = AF.request(
          url,
          parameters: request,
          encoder: .urlEncodedForm(encoder: .api)
        )
        .validate(statusCode: CollectionOfOne(200))
        .serializingDecodable(ListMangasResponse.self, decoder: .api)

        return try await task.value
      },
      mangaFeed: { request in
        let task = AF.request(request)
          .validate(statusCode: CollectionOfOne(200))
          .serializingDecodable(MangaFeedResponse.self, decoder: .api)

        return try await task.value
      },
      getManga: { request in
        let task = AF.request(request)
          .validate(statusCode: CollectionOfOne(200))
          .serializingDecodable(GetMangaResponse.self, decoder: .api)

        return try await task.value
      }
    )
  }

  public static let testValue = MangaAPIClient()
}

public extension DependencyValues {
  var mangaAPI: MangaAPIClient {
    get { self[MangaAPIClient.self] }
    set { self[MangaAPIClient.self] = newValue }
  }
}
