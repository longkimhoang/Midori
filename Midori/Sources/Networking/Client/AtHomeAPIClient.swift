//
//  AtHomeAPIClient.swift
//
//
//  Created by Long Kim on 15/5/24.
//

import Alamofire
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct AtHomeAPIClient: Sendable {
  public var getURL: @Sendable (_ request: GetAtHomeURLRequest) async throws -> GetAtHomeURLResponse
}

extension AtHomeAPIClient: DependencyKey {
  public static var liveValue: AtHomeAPIClient {
    AtHomeAPIClient(
      getURL: { request in
        let task = AF.request(request)
          .validate(statusCode: CollectionOfOne(200))
          .serializingDecodable(GetAtHomeURLResponse.self, decoder: .api)

        return try await task.value
      }
    )
  }

  public static let testValue = AtHomeAPIClient()
}

public extension DependencyValues {
  var atHomeAPI: AtHomeAPIClient {
    get { self[AtHomeAPIClient.self] }
    set { self[AtHomeAPIClient.self] = newValue }
  }
}
