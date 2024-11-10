//
//  LatestChapterView.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import SwiftUI

struct LatestChapterView: View {
    @Environment(\.displayScale) private var displayScale

    let manga: String
    let chapter: String
    let group: String
    let coverImage: Image?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                CoverImageView(image: coverImage)
                    .frame(width: 60)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.separator, lineWidth: 1 / displayScale)
                    }

                VStack(alignment: .leading) {
                    Text(manga)
                        .font(.headline)

                    Group {
                        Text(chapter)
                        ScanlationGroupLabel(group: group)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                .lineLimit(1)
                .anchorPreference(key: SeparatorLeadingAnchor.self, value: .leading) { $0 }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 8)
            .padding(.trailing, 8)

            Rectangle()
                .fill(.clear)
                .frame(height: 1 / displayScale)
        }
        .overlayPreferenceValue(SeparatorLeadingAnchor.self) { value in
            if let value {
                GeometryReader { geometry in
                    VStack {
                        Spacer(minLength: 0)

                        Rectangle()
                            .fill(.separator)
                            .frame(height: 1 / displayScale)
                            .padding(.leading, geometry[value].x)
                    }
                }
            }
        }
    }

    private struct SeparatorLeadingAnchor: PreferenceKey {
        static let defaultValue: Anchor<CGPoint>? = nil

        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = nextValue()
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    LatestChapterView(
        manga: "Mieruko-chan",
        chapter: "Vol. 11 - Ch. 60",
        group: "Pixel Horror",
        coverImage: Image(.mangaCoverPreview)
    )
}
