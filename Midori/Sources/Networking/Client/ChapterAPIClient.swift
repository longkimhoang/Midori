//
//  ChapterAPIClient.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Alamofire
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct ChapterAPIClient: Sendable {
  public var listChapters: @Sendable (
    _ request: ListChaptersRequest
  ) async throws -> ListChaptersResponse
}

extension ChapterAPIClient: DependencyKey {
  public static var liveValue: ChapterAPIClient {
    let baseURL = URL(string: "https://api.mangadex.org/chapter")!
    return ChapterAPIClient(
      listChapters: { request in
        let url = baseURL
        let task = AF.request(
          url,
          parameters: request,
          encoder: .urlEncodedForm(encoder: .api)
        )
        .validate(statusCode: CollectionOfOne(200))
        .serializingDecodable(ListChaptersResponse.self, decoder: .api)

        return try await task.value
      }
    )
  }

  public static let testValue = ChapterAPIClient()
}

public extension DependencyValues {
  var chapterAPI: ChapterAPIClient {
    get { self[ChapterAPIClient.self] }
    set { self[ChapterAPIClient.self] = newValue }
  }
}
