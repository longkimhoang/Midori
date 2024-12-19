//
//  ReaderToolbarView.swift
//  UI
//
//  Created by Long Kim on 19/12/24.
//

import MidoriViewModels
import SwiftUI

struct ReaderToolbarView: View {
    @State private var showsScrubber: Bool = false
    @ScaledMetric(relativeTo: .body) private var buttonHeight: CGFloat = 44

    let indices: String
    let pageCount: Int
    @ObservedObject var pageScrubber: PageScrubberViewModel
    @ObservedObject var readerOptions: ReaderOptionsViewModel
    let onShowGalleryTapped: () -> Void

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .lastTextBaseline)) {
            VStack {
                pageIndexButton
            }
            HStack {
                Spacer()
                galleryButton
            }
        }
        .popover(isPresented: $showsScrubber, arrowEdge: .bottom) {
            PageScrubberView(viewModel: pageScrubber)
                .presentationCompactAdaptation(.none)
                .environment(\.layoutDirection, readerOptions.useRightToLeftLayout ? .rightToLeft : .leftToRight)
        }
        .buttonStyle(ToolbarButtonStyle())
        .padding()
        .frame(maxWidth: .infinity)
    }

    private var galleryButton: some View {
        Button {
            onShowGalleryTapped()
        } label: {
            Label(String(localized: "Show all pages", bundle: .module), systemImage: "rectangle.grid.3x2")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonBorderShape(.circle)
        .frame(width: buttonHeight, height: buttonHeight)
        .labelStyle(.iconOnly)
    }

    private var pageIndexButton: some View {
        Button {
            showsScrubber.toggle()
        } label: {
            Text(verbatim: "\(indices) / \(pageCount)")
                .padding(.horizontal)
                .frame(maxHeight: .infinity)
        }
        .buttonBorderShape(.capsule)
        .frame(height: buttonHeight)
        .accessibilityLabel(String(localized: "Page \(indices) of \(pageCount)", bundle: .module))
        .accessibilityHint(String(localized: "Shows a slider for navigating through pages", bundle: .module))
    }
}

private struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.tint)
            .animation(.snappy(duration: 0.2)) {
                $0.opacity(configuration.isPressed ? 0.3 : 1)
            }
            .background(Material.bar, in: .capsule)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @StateObject var scrubber = PageScrubberViewModel()
    @Previewable @StateObject var readerOptions = ReaderOptionsViewModel()

    ReaderToolbarView(
        indices: "1",
        pageCount: 5,
        pageScrubber: scrubber,
        readerOptions: readerOptions,
        onShowGalleryTapped: {}
    )
    .onAppear {
        scrubber.numberOfPages = 5
    }
}
