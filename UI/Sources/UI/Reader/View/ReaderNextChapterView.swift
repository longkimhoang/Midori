//
//  ReaderNextChapterView.swift
//  UI
//
//  Created by Long Kim on 1/12/24.
//

import NukeUI
import SwiftUI

struct ReaderNextChapterView: View {
    @Environment(\.dismiss) private var dismiss

    let manga: String
    let currentChapter: String
    let nextChapter: String?
    let coverImageURL: URL?
    let navigateToNextChapter: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                LazyImage(request: coverImageRequest) { state in
                    CoverImageView(image: state.image)
                        .frame(width: 120)
                        .coverImageShadow()
                        .padding(.bottom)
                }
                .pipeline(.midoriApp)

                Text(currentChapter)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(manga)
                    .font(.title2.weight(.medium))

                Group {
                    if let nextChapter {
                        Button {
                            navigateToNextChapter()
                        } label: {
                            Text("Go to chapter \(nextChapter)", bundle: .module)
                        }
                    } else {
                        noMoreChaptersView
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
            .lineLimit(4)
            .multilineTextAlignment(.center)
            .padding()
        }
        .defaultScrollAnchor(.center)
        .scrollBounceBehavior(.basedOnSize)
    }

    private var coverImageRequest: ImageRequest {
        ImageRequest(url: coverImageURL, processors: [.resize(width: 120)])
    }

    @ViewBuilder private var noMoreChaptersView: some View {
        Button(role: .cancel) {
            dismiss()
        } label: {
            Text("Return to manga", bundle: .module)
        }

        Text("No newer chapters available", bundle: .module)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

#Preview("Next chapter available") {
    ReaderNextChapterView(
        manga: "Senpai, Jitaku Keibiin no Koyou wa Ikaga desu ka?",
        currentChapter: "Chapter 1",
        nextChapter: "2",
        coverImageURL: nil,
        navigateToNextChapter: {}
    )
}

#Preview("Next chapter unavailable") {
    ReaderNextChapterView(
        manga: "Senpai, Jitaku Keibiin no Koyou wa Ikaga desu ka?",
        currentChapter: "Chapter 1",
        nextChapter: nil,
        coverImageURL: nil,
        navigateToNextChapter: {}
    )
}
