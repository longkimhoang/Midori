//
//  RecentlyAddedMangaView.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import UIKit

struct RecentlyAddedMangaConfiguration: UIContentConfiguration {
    let title: String
    let coverImage: UIImage?

    func makeContentView() -> any UIView & UIContentView {
        RecentlyAddedMangaContentView(configuration: self)
    }

    func updated(for _: any UIConfigurationState) -> RecentlyAddedMangaConfiguration {
        self
    }
}

final class RecentlyAddedMangaContentView: UIView, UIContentView {
    private static let contentViewNib = UINib(nibName: "RecentlyAddedMangaContentView", bundle: .module)

    @IBOutlet var containerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var coverImageView: UIImageView!

    var configuration: any UIContentConfiguration {
        didSet {
            guard let configuration = configuration as? RecentlyAddedMangaConfiguration else {
                return
            }

            configure(with: configuration)
        }
    }

    init(configuration: RecentlyAddedMangaConfiguration) {
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

    func configure(with configuration: RecentlyAddedMangaConfiguration) {
        titleLabel.text = configuration.title
        coverImageView.image = configuration.coverImage
    }
}
