//
//  ListMangas.swift
//
//
//  Created by Long Kim on 28/02/2024.
//

import Common
import Foundation
import HelperCoders
import MetaCodable

@Codable
public struct ListMangas {
  public let limit: Int
  public let offset: Int
}

// MARK: - Request

extension ListMangas {

  @Codable
  public struct Parameters {
    public let limit: Int?
    public let offset: Int?
    @Default(true) public let hasAvailableChapters: Bool
    @CodedBy(DateCoder(formatter: .api)) public let createdAtSince: Date?
    public let order: Order?

    @Codable
    @MemberInit
    public struct Order {

      public typealias SortOrder = Common.SortOrder

      public let latestUploadChapter: SortOrder?
      public let followedCount: SortOrder?
      public let createdAt: SortOrder?
    }
  }
}
