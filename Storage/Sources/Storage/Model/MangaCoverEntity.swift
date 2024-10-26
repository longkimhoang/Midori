//
//  MangaCoverEntity.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Foundation
import SwiftData

@Model
public final class MangaCoverEntity {
    #Unique<MangaCoverEntity>([\.id])

    public var id: UUID
    public var fileName: String
    public var volume: String?

    public init(id: UUID, fileName: String, volume: String? = nil) {
        self.id = id
        self.fileName = fileName
        self.volume = volume
    }

    @Relationship var manga: MangaEntity?
}
