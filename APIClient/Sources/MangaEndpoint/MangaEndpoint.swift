//
//  MangaEndpoint.swift
//
//
//  Created by Long Kim on 26/02/2024.
//

import Alamofire
import Foundation

/// A namespace for Manga related APIs
public enum MangaEndpoint {}

// MARK: - List Mangas

extension MangaEndpoint {
  /// Search a list of mangas.
  public static func listMangas(
    parameters: ListMangas.Parameters? = nil
  ) async throws -> ListMangas {
    try await AF.request(Router.listMangas(parameters))
      .validate(statusCode: CollectionOfOne(200))
      .serializingDecodable(ListMangas.self)
      .value
  }
}
