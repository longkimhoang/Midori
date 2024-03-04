//
//  Author.swift
//
//
//  Created by Long Kim on 04/03/2024.
//

import CoreData
import Foundation

@objc(Author)
public final class Author: NSManagedObject {
  @NSManaged public var authorID: UUID
  @NSManaged public var name: String
  @NSManaged public var imageURL: URL?
}
