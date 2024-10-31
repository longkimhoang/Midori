//
//  CoverImageView.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import SwiftUI

struct CoverImageView: View {
    let image: Image?

    var body: some View {
        Rectangle()
            .fill(.fill.secondary)
            .overlay {
                if let image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .clipShape(.rect(cornerRadius: 8))
            .aspectRatio(0.7, contentMode: .fit)
    }
}
