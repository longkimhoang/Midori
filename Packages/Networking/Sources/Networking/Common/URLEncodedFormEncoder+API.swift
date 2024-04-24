//
//  URLEncodedFormEncoder+API.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Alamofire
import Foundation

extension URLEncodedFormEncoder {
  /// The  shared`URLEncodedFormEncoder` instance configured to encode MangaDex API responses.
  static let api: URLEncodedFormEncoder = {
    let encoder = URLEncodedFormEncoder(
      dateEncoding: .custom { date in
        date.formatted(.iso8601.year().month().day().time(includingFractionalSeconds: false))
      }
    )

    return encoder
  }()
}

extension URLEncodedFormEncoder: @unchecked Sendable {}
