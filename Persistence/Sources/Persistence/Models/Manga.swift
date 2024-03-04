//
//  Manga.swift
//
//
//  Created by Long Kim on 04/03/2024.
//

import CoreData
import Foundation

@objc(Manga)
public final class Manga: NSManagedObject {
  @NSManaged public var mangaID: UUID
  @NSManaged public var title: String
  @NSManaged public var coverImageURL: URL?
}

// MARK: - Relationships

extension Manga {
  @NSManaged public var artist: Author
  @NSManaged public var author: Author?
}

// MARK: - Conformance

extension Manga: Identifiable {
  public var id: NSManagedObjectID { objectID }
}
