//
//  PersistenceController.swift
//
//
//  Created by Long Kim on 03/03/2024.
//

import CoreData
import Dependencies
import Foundation
import os.log
import System

private let logger = Logger(subsystem: "com.longkimhoang.Midori", category: "Persistence")

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

    container.loadPersistentStores { description, error in
      if let error {
        logger.error("Failed to initialize store \(description) with error \(error)")
      } else {
        logger.debug("Initialized store \(description)")
      }
    }
  }
}

extension PersistenceController: DependencyKey {
  public static let liveValue = try! PersistenceController()
  public static let previewValue = try! PersistenceController(inMemory: true)
}

extension DependencyValues {
  public var persistenceController: PersistenceController {
    get { self[PersistenceController.self] }
    set { self[PersistenceController.self] = newValue }
  }
}
