//
//  LatestChapterView.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import UIKit

struct LatestChapterConfiguration: UIContentConfiguration {
    let manga: String
    let chapter: String
    let group: String
    let coverImage: UIImage?

    func makeContentView() -> any UIView & UIContentView {
        LatestChapterContentView(configuration: self)
    }

    func updated(for _: any UIConfigurationState) -> LatestChapterConfiguration {
        self
    }
}

final class LatestChapterContentView: UIView, UIContentView {
    private static let contentViewNib = UINib(nibName: "LatestChapterContentView", bundle: .module)

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var mangaLabel: UILabel!
    @IBOutlet private var chapterLabel: UILabel!
    @IBOutlet private var groupLabel: UILabel!
    @IBOutlet private var coverImageView: UIImageView!

    var configuration: any UIContentConfiguration {
        didSet {
            guard let configuration = configuration as? LatestChapterConfiguration else {
                return
            }

            configure(with: configuration)
        }
    }

    init(configuration: LatestChapterConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)

        Self.contentViewNib.instantiate(withOwner: self)

        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        coverImageView.layer.cornerRadius = 8
        coverImageView.layer.masksToBounds = true
        coverImageView.layer.borderColor = UIColor.separator.cgColor

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        configure(with: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let displayScale = max(1, traitCollection.displayScale)
        coverImageView.layer.borderWidth = 1 / displayScale
    }

    func configure(with configuration: LatestChapterConfiguration) {
        mangaLabel.text = configuration.manga
        chapterLabel.text = configuration.chapter
        groupLabel.text = configuration.group
        coverImageView.image = configuration.coverImage
    }
}
