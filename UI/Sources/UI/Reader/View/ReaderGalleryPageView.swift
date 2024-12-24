//
//  ReaderGalleryPageView.swift
//  UI
//
//  Created by Long Kim on 24/12/24.
//

import SwiftUI

struct ReaderGalleryPageView: View {
    let pageNumber: Int
    let isSelected: Bool
    let image: Image?

    var body: some View {
        VStack {
            CoverImageView(image: image)

            Text("Page \(pageNumber)", bundle: .module)
                .font(.caption.weight(isSelected ? .semibold : .regular))
        }
    }
}

#Preview("Normal", traits: .sizeThatFitsLayout) {
    ReaderGalleryPageView(pageNumber: 1, isSelected: false, image: Image(.mangaCoverPreview))
        .frame(width: 200)
        .padding()
}

#Preview("Selected", traits: .sizeThatFitsLayout) {
    ReaderGalleryPageView(pageNumber: 1, isSelected: true, image: Image(.mangaCoverPreview))
        .frame(width: 200)
        .padding()
}
