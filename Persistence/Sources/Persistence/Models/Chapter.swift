//
//  Chapter.swift
//
//
//  Created by Long Kim on 07/03/2024.
//

import CoreData
import Foundation

@objc(Chapter)
public final class Chapter: NSManagedObject {
  // MARK: - Attributes

  @NSManaged public var chapterID: UUID
  @NSManaged public var title: String?
  @NSManaged public var chapter: String?

  // MARK: - Relationships

  @NSManaged public var manga: Manga
}

extension Chapter: Identifiable {}
