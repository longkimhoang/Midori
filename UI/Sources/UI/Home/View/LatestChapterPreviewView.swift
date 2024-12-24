//
//  LatestChapterPreviewView.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import SwiftUI

struct LatestChapterPreviewView: View {
    @Environment(\.displayScale) private var displayScale

    let manga: String
    let chapter: String
    let group: String
    let coverImage: Image?

    var body: some View {
        VStack {
            CoverImageView(image: coverImage)
                .frame(width: 100)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.separator, lineWidth: 1 / displayScale)
                }

            Group {
                Text(manga)
                    .font(.headline)

                Group {
                    Text(chapter)
                    ScanlationGroupLabel(group: group)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
            .lineLimit(2)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}
