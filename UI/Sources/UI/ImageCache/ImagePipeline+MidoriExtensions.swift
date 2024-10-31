//
//  ImagePipeline+MidoriExtensions.swift
//  UI
//
//  Created by Long Kim on 30/10/24.
//

import Nuke

extension ImagePipeline {
    /// Shared pipeline for the app.
    static let midoriApp: ImagePipeline = ImagePipeline {
        $0.isUsingPrepareForDisplay = true
    }
}
