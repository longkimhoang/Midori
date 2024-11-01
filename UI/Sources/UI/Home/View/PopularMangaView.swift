//
//  PopularMangaView.swift
//  UI
//
//  Created by Long Kim on 29/10/24.
//

import UIKit

struct PopularMangaConfiguration: UIContentConfiguration {
    let title: String
    let authors: String?
    var isHighlighted: Bool = false
    let coverImage: UIImage?

    func makeContentView() -> any UIView & UIContentView {
        PopularMangaContentView(configuration: self)
    }

    func updated(for _: any UIConfigurationState) -> PopularMangaConfiguration {
        self
    }
}

final class PopularMangaContentView: UIView, UIContentView {
    private static let contentViewNib = UINib(nibName: "PopularMangaContentView", bundle: .module)

    @IBOutlet var containerView: UIView!
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var imageContainerView: UITableViewHeaderFooterView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorsLabel: UILabel!

    var configuration: any UIContentConfiguration {
        didSet {
            guard let configuration = configuration as? PopularMangaConfiguration else {
                return
            }

            configure(with: configuration)
        }
    }

    init(configuration: PopularMangaConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)

        Self.contentViewNib.instantiate(withOwner: self)

        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true

        coverImageView.layer.cornerRadius = 8
        coverImageView.layer.masksToBounds = true

        var backgroundConfiguration = UIBackgroundConfiguration.clear()
        backgroundConfiguration.cornerRadius = 8
        backgroundConfiguration.shadowProperties.offset = CGSize(width: 0, height: 12)
        backgroundConfiguration.shadowProperties.opacity = 0.15
        backgroundConfiguration.shadowProperties.radius = 8

        imageContainerView.backgroundConfiguration = backgroundConfiguration

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

    func configure(with configuration: PopularMangaConfiguration) {
        titleLabel.text = configuration.title
        authorsLabel.text = configuration.authors
        authorsLabel.isHidden = configuration.authors == nil
        coverImageView.image = configuration.coverImage
    }
}
