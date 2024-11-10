//
//  HomeSectionHeaderLabelView.swift
//  UI
//
//  Created by Long Kim on 29/10/24.
//

import SwiftUI

struct HomeSectionHeaderLabelView: View {
    let content: String

    var body: some View {
        Text("Popular new titles", bundle: .module)
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}
