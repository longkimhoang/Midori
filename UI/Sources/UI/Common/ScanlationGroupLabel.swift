//
//  ScanlationGroupLabel.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import SwiftUI

struct ScanlationGroupLabel: View {
    let group: String

    var body: some View {
        Label(group, systemImage: "person.2.fill")
            .labelStyle(ScanlationGroupLabelStyle())
    }
}

private struct ScanlationGroupLabelStyle: LabelStyle {
    @Environment(\.font) private var font

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
            configuration.title
        }
        .font(font ?? .subheadline)
    }
}
