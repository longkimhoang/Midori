//
//  MangaDetailDescriptionViewController.swift
//  UI
//
//  Created by Long Kim on 9/11/24.
//

import Foundation
import SafariServices
import SnapKit
import SwiftUI
import UIKit

final class MangaDetailDescriptionViewController: UIViewController {
    private lazy var hostingController = UIHostingController<MangaSynopsisContentView?>(rootView: nil)
    private lazy var coordinator = MangaSynopsisContentView.Coordinator()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .systemBackground

        hostingController.sizingOptions = [.preferredContentSize, .intrinsicContentSize]
        addChild(hostingController)
        hostingController.didMove(toParent: self)
        view.addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinator.openURL = { [weak self] url in
            let safariViewController = SFSafariViewController(url: url)
            self?.present(safariViewController, animated: true)
        }
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        coordinator.layoutMargins.leading = view.directionalLayoutMargins.leading
        coordinator.layoutMargins.trailing = view.directionalLayoutMargins.trailing
    }

    func setContent(_ content: String) {
        let contentView = MangaSynopsisContentView(content: content, coordinator: coordinator)
        hostingController.rootView = contentView
    }
}

private struct MangaSynopsisContentView: View {
    let content: String
    let coordinator: Coordinator

    var body: some View {
        ScrollView {
            Text(attributedContent)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
                .padding(coordinator.layoutMargins)
                .containerRelativeFrame(.horizontal, alignment: .leading)
        }
        .environment(\.openURL, OpenURLAction {
            coordinator.openURL($0)
            return .handled
        })
    }

    var attributedContent: AttributedString {
        let attributes = AttributeContainer()
            .font(.body)

        guard let attributedContent = try? AttributedString(
            markdown: content,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) else {
            return AttributedString(content).mergingAttributes(attributes)
        }

        return attributedContent.mergingAttributes(attributes)
    }

    @Observable
    final class Coordinator {
        var layoutMargins = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        var openURL: (URL) -> Void = { _ in }
    }
}

#Preview {
    let viewController = MangaDetailDescriptionViewController()
    viewController.setContent("""
    "Hey, boyfriend, how you doing?"

    Souta Sakuhara is a first-year high school boy. His first ever girlfriend has just been stolen away from him by a "girlfriend." That girlfriend is Shizuno Mizushima, a tomboy who's also the tallest girl he's ever met, who's now his hated rival in love, taunting him with it. But then…

    "Since nobody else wants to be your girlfriend, how about you go out with me?"

    She suddenly pins him against the wall! She also started saying, "Give me a month, and I'll make you fall in love with me…… I'm not going to let you go so easily!"

    A one-way romantic comedy in which a handsome and beautiful girl will tempt you every day!
    """)

    return UINavigationController(rootViewController: viewController)
}

#Preview("Short text") {
    let viewController = MangaDetailDescriptionViewController()
    viewController.setContent("Short text")

    return UINavigationController(rootViewController: viewController)
}
