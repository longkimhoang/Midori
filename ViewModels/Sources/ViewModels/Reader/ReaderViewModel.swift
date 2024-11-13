//
//  ReaderViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 12/11/24.
//

import Combine
import Foundation
import MidoriServices

@MainActor
public final class ReaderViewModel {
    let chapterID: UUID

    public init(chapterID: UUID) {
        self.chapterID = chapterID
    }
}
