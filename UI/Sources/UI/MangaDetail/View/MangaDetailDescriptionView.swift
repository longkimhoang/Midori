//
//  MangaDetailDescriptionView.swift
//  UI
//
//  Created by Long Kim on 8/11/24.
//

import SwiftUI

struct MangaDetailDescriptionView: View {
    @Environment(\.lineLimit) private var lineLimit
    @Environment(\.expandMangaDescription) private var expandMangaDescription
    @State private var isTruncated: Bool = false

    let content: String

    var body: some View {
        Button {
            expandMangaDescription()
        } label: {
            Text(attributedContent)
                .overlay(alignment: .trailingLastTextBaseline) {
                    ViewThatFits {
                        Text(attributedContent)
                            .lineLimit(nil)
                            .hidden()
                            .onAppear {
                                isTruncated = false
                            }

                        Text("More", bundle: .module)
                            .font(.subheadline.weight(.medium).smallCaps())
                            .padding(.leading, 16)
                            .background {
                                GeometryReader { geometry in
                                    Rectangle()
                                        .fill(moreLabelShapeStyle(width: geometry.size.width))
                                }
                            }
                            .onAppear {
                                isTruncated = true
                            }
                    }
                }
                .containerRelativeFrame(.horizontal)
        }
        .buttonStyle(DescriptionExpansionButtonStyle())
        .disabled(!isTruncated)
        .accessibilityHint("Views the full description of the manga.", isEnabled: isTruncated)
    }

    private var attributedContent: AttributedString {
        AttributedString(content, attributes: AttributeContainer()
            .font(UIFont.preferredFont(forTextStyle: .subheadline))
            .foregroundColor(UIColor.secondaryLabel))
    }

    private func moreLabelShapeStyle(width: CGFloat) -> some ShapeStyle {
        let backgroundColor = Color(uiColor: .systemBackground)
        return LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: backgroundColor, location: 16 / width),
                .init(color: backgroundColor, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct ExpandMangaDescriptionAction {
    let handler: @MainActor () -> Void

    @MainActor func callAsFunction() {
        handler()
    }
}

extension EnvironmentValues {
    @Entry var expandMangaDescription = ExpandMangaDescriptionAction {}
}

private struct DescriptionExpansionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

#Preview("Truncated", traits: .sizeThatFitsLayout) {
    MangaDetailDescriptionView(content: """
    "Hey, boyfriend, how you doing?"

    Souta Sakuhara is a first-year high school boy. His first ever girlfriend has just been stolen away from him by a "girlfriend." That girlfriend is Shizuno Mizushima, a tomboy who's also the tallest girl he's ever met, who's now his hated rival in love, taunting him with it. But then…

    "Since nobody else wants to be your girlfriend, how about you go out with me?"

    She suddenly pins him against the wall! She also started saying, "Give me a month, and I'll make you fall in love with me…… I'm not going to let you go so easily!"

    A one-way romantic comedy in which a handsome and beautiful girl will tempt you every day!
    """)
    .lineLimit(4)
}

#Preview("Normal", traits: .sizeThatFitsLayout) {
    MangaDetailDescriptionView(content: """
    "Hey, boyfriend, how you doing?"
    """)
    .lineLimit(4)
}
