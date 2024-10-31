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
        HStack {
            CoverImageView(image: coverImage)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.separator, lineWidth: 1 / displayScale)
                }
                .frame(width: 60)

            VStack(alignment: .leading) {
                Text(manga)
                    .font(.headline)
                    .anchorPreference(key: SeparatorLeadingPreferenceKey.self, value: .leading) { $0 }

                Text(chapter)
                    .font(.subheadline)

                Text(group)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .lineLimit(1)

            Spacer()
        }
        .padding(.vertical, 8)
        .overlayPreferenceValue(SeparatorLeadingPreferenceKey.self) { value in
            if let value {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(.separator)
                            .frame(height: 1 / displayScale)
                            .padding(.leading, geometry[value].x)
                    }
                }
            }
        }
    }

    private struct SeparatorLeadingPreferenceKey: PreferenceKey {
        static let defaultValue: Anchor<CGPoint>? = nil

        static func reduce(value: inout Anchor<CGPoint>?, nextValue: () -> Anchor<CGPoint>?) {
            value = nextValue()
        }
    }
}
