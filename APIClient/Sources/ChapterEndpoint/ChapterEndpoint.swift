//
//  ChapterEndpoint.swift
//
//
//  Created by Long Kim on 06/03/2024.
//

import Alamofire

/// A namespace for Chapter related APIs
public enum ChapterEndpoint {}

// MARK: - List Chapters

extension ChapterEndpoint {
  /// Chapter list.
  public static func listChapters(
    parameters: ListChapters.Parameters? = nil
  ) async throws -> ListChapters {
    try await AF.request(Router.listChapters(parameters))
      .validate(statusCode: CollectionOfOne(200))
      .serializingDecodable(ListChapters.self)
      .value
  }
}
