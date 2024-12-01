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

struct CoverImageShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                .background.shadow(.drop(color: Color(white: 0, opacity: 0.15), radius: 8, y: 12)),
                in: .rect(cornerRadius: 8)
            )
    }
}

extension View {
    func coverImageShadow() -> some View {
        modifier(CoverImageShadowModifier())
    }
}
