//
//  MangaDetailDescriptionViewController.swift
//  UI
//
//  Created by Long Kim on 9/11/24.
//

import Foundation
import UIKit

final class MangaDetailDescriptionViewController: UIViewController {
    @ViewLoading var textView: UITextView

    init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .close, primaryAction: UIAction { [weak self] _ in
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

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.textColor = .label
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.textContainer.lineFragmentPadding = 0

        view.addSubview(textView)
        self.view = view
        self.textView = textView

        NSLayoutConstraint.activate([
            textView.frameLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            textView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        textView.contentInset = .init(
            top: 8,
            left: view.layoutMargins.left,
            bottom: 8,
            right: view.layoutMargins.right
        )
    }

    func setContent(_ content: String) {
        guard var attributedContent = try? AttributedString(
            markdown: content,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) else {
            return
        }

        attributedContent.mergeAttributes(AttributeContainer()
            .font(.preferredFont(forTextStyle: .body))
            .foregroundColor(.label))

        textView.attributedText = NSAttributedString(attributedContent)
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
