//
//  JSONDecoder+API.swift
//
//
//  Created by Long Kim on 23/4/24.
//

import Alamofire
import Foundation

extension JSONDecoder {
  /// The  shared `JSONDecoder` instance configured to decode MangaDex API responses.
  static let api: JSONDecoder = {
    let formatStyle = Date.ISO8601FormatStyle().year().month().day()
      .time(includingFractionalSeconds: false)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let dateString = try container.decode(String.self)
      return try Date(dateString, strategy: formatStyle)
    }

    return decoder
  }()
}

extension DataDecoder where Self == JSONDecoder {
  /// The  shared `DataDecoder` instance configured to decode MangaDex API responses.
  static var api: JSONDecoder { .api }
}
