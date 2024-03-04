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
}

extension Manga: Identifiable {
  public var id: NSManagedObjectID { objectID }
}
