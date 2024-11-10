//
//  MangaDetailHeaderView.swift
//  UI
//
//  Created by Long Kim on 3/11/24.
//

import SwiftUI

struct MangaDetailHeaderView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let title: String
    let alternateTitle: String?
    let subtitle: AttributedString?
    let coverImage: Image?
    let description: String?
    let rating: Double

    var body: some View {
        layout {
            CoverImageView(image: coverImage)
                .modifier(MangaCoverModifier())

            if horizontalSizeClass == .regular {
                VStack(alignment: .leading) {
                    content
                }

                Spacer(minLength: 0)
            } else {
                content
            }
        }
        .padding(.vertical, horizontalSizeClass == .regular ? 20 : nil)
    }

    private var layout: AnyLayout {
        if horizontalSizeClass == .regular {
            AnyLayout(HStackLayout(alignment: .bottom, spacing: 16))
        } else {
            AnyLayout(VStackLayout(alignment: .center))
        }
    }

    private var titleTextAlignment: TextAlignment {
        if horizontalSizeClass == .regular {
            .leading
        } else {
            .center
        }
    }

    @ViewBuilder private var content: some View {
        Group {
            Text(title)
                .font(.title.weight(.medium))

            if let alternateTitle {
                Text(alternateTitle)
                    .font(.subheadline)
            }
        }
        .multilineTextAlignment(titleTextAlignment)
        .lineLimit(4)
        .truncationMode(.middle)

        MangaInfoLayout {
            authorsLabel
            ratingLabel
        }
        .padding(.top, 2)

        if let description {
            MangaDetailDescriptionView(content: description)
                .lineLimit(2)
                .padding(.top, 8)
        }
    }

    @ViewBuilder private var authorsLabel: some View {
        if let subtitle {
            Label {
                Text(subtitle)
            } icon: {
                Image(systemName: "person.2.fill")
            }
        }
    }

    private var ratingLabel: some View {
        Label {
            Text(rating, format: .number.precision(.fractionLength(...2)))
        } icon: {
            Image(systemName: "star.fill")
        }
    }
}

private struct MangaInfoLayout<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Group(subviews: content()) { subviews in
                ForEach(subviews: subviews.dropLast()) { subview in
                    subview
                    Text(verbatim: "•")
                }

                subviews.last
            }
            .foregroundStyle(.secondary)
            .font(.subheadline)
            .labelStyle(InfoLabelStyle())
        }
    }

    struct InfoLabelStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                configuration.icon
                configuration.title
            }
            .foregroundStyle(.secondary)
            .font(.subheadline)
        }
    }
}

private struct MangaCoverModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        content
            .containerRelativeFrame(
                .horizontal,
                count: horizontalSizeClass == .regular ? 4 : 3,
                span: 1,
                spacing: 0
            )
            .background(
                .background.shadow(.drop(color: Color(white: 0, opacity: 0.15), radius: 8, y: 12)),
                in: .rect(cornerRadius: 8)
            )
    }
}
