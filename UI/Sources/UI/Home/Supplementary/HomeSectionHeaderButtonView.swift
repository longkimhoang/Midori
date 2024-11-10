//
//  HomeSectionHeaderButtonView.swift
//  UI
//
//  Created by Long Kim on 29/10/24.
//

import SwiftUI

struct HomeSectionHeaderButtonView: View {
    let label: String
    let handler: () -> Void

    var body: some View {
        Button(action: handler) {
            Label(label, systemImage: "chevron.right")
                .labelStyle(HomeSectionHeaderButtonLabelStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.borderless)
        .foregroundStyle(.primary)
        .accessibilityAddTraits(.isHeader)
    }
}

private struct HomeSectionHeaderButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .lastTextBaseline) {
            configuration.title
            configuration.icon
                .foregroundStyle(.secondary)
        }
        .font(.title)
        .imageScale(.small)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    HomeSectionHeaderButtonView(label: "A button") {
        print("Button pressed")
    }
}
