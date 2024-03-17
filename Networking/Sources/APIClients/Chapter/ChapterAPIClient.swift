//
//  ChapterAPIClient.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import Alamofire
import Dependencies
import DependenciesMacros

@DependencyClient
public struct ChapterAPIClient {
  public var listChapters: (_ parameters: ListChaptersParameters) async throws -> ListChapters
}

extension ChapterAPIClient: DependencyKey {
  public static var liveValue: ChapterAPIClient {
    ChapterAPIClient(
      listChapters: { parameters in
        try await AF.request(ChapterRouter.listChapters(parameters))
          .validate(statusCode: CollectionOfOne(200))
          .serializingDecodable(ListChapters.self)
          .value
      }
    )
  }
}

public extension DependencyValues {
  var chapterAPI: ChapterAPIClient {
    get { self[ChapterAPIClient.self] }
    set { self[ChapterAPIClient.self] = newValue }
  }
}
