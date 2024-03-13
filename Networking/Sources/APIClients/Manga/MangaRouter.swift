//
//  MangaRouter.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import Alamofire
import Common
import Foundation

enum MangaRouter: RouterProtocol {
  case listMangas(ListMangasParameters?)

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
      request = try URLEncodedFormParameterEncoder.default.encode(parameters, into: request)
    }
  }
}
