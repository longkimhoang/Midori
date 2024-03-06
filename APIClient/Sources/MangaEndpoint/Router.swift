//
//  Router.swift
//
//
//  Created by Long Kim on 28/02/2024.
//

import Alamofire
import APICommon
import Foundation

enum Router: RouterProtocol {
  case listMangas(ListMangas.Parameters?)

  var baseURL: URL {
    URL(string: "https://api.mangadex.org")!
  }

  var path: String {
    switch self {
    case .listMangas: "manga"
    }
  }

  func modifyRequest(_ request: inout URLRequest) throws {
    switch self {
    case let .listMangas(parameters):
      let defaultParameters = [
        "includes": ["cover_art", "artist", "author"],
      ]
      request = try URLEncodedFormParameterEncoder.default.encode(parameters, into: request)
      request = try URLEncodedFormParameterEncoder.default.encode(defaultParameters, into: request)
    }
  }
}
