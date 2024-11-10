//
//  MangaDetailDescriptionViewController.swift
//  UI
//
//  Created by Long Kim on 9/11/24.
//

import Foundation
import SnapKit
import SwiftUI
import UIKit

final class MangaDetailDescriptionViewController: UIViewController {
    private lazy var hostingController = UIHostingController<MangaSynopsisContentView?>(rootView: nil)

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

        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(scrollView.contentLayoutGuide)
            make.horizontalEdges.equalTo(view.layoutMarginsGuide)
            make.width.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide).priority(.low)
        }

        hostingController.sizingOptions = [.preferredContentSize, .intrinsicContentSize]
        addChild(hostingController)
        hostingController.didMove(toParent: self)
        contentView.addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(scrollView.contentLayoutGuide)
        }

        self.view = view
    }

    func setContent(_ content: String) {
        let contentView = MangaSynopsisContentView(content: content)
        hostingController.rootView = contentView
    }
}

private struct MangaSynopsisContentView: View {
    let content: String

    var body: some View {
        Text(attributedContent)
            .multilineTextAlignment(.leading)
            .textSelection(.enabled)
    }

    var attributedContent: AttributedString {
        let attributes = AttributeContainer()
            .font(.body)
            .foregroundColor(.primary)

        guard let attributedContent = try? AttributedString(
            markdown: content,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) else {
            return AttributedString(content).mergingAttributes(attributes)
        }

        return attributedContent.mergingAttributes(attributes)
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
