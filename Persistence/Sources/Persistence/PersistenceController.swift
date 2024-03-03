//
//  PersistenceController.swift
//
//
//  Created by Long Kim on 03/03/2024.
//

import CoreData
import Foundation
import System

public struct PersistenceController {
  public let container: NSPersistentContainer

  public init(inMemory: Bool = false) throws {
    guard let modelURL = Bundle.module.resourceURL?.appending(path: "Model.momd"),
          let model = NSManagedObjectModel(contentsOf: modelURL)
    else {
      throw PersistenceError.dataModelNotFound
    }

    container = NSPersistentContainer(name: "Model", managedObjectModel: model)
    if inMemory, let description = container.persistentStoreDescriptions.first {
      description.url = URL(filePath: FilePath("/dev/null"))
    }
  }
}
