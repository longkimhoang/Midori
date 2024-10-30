//
//  PopularMangaView.swift
//  UI
//
//  Created by Long Kim on 29/10/24.
//

import SwiftUI
import UIKit
import UIKitNavigation

struct PopularMangaConfiguration: Equatable {
    let title: String
    let authors: String?
    var isHighlighted: Bool = false
    var coverImage: UIImage?
}

extension PopularMangaConfiguration: UIContentConfiguration {
    func makeContentView() -> UIView & UIContentView {
        PopularMangaContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> PopularMangaConfiguration {
        guard let state = state as? UICellConfigurationState else {
            return self
        }

        var updatedConfiguration = self
        updatedConfiguration.isHighlighted = state.isHighlighted
        return updatedConfiguration
    }
}

final class PopularMangaContentView: UIView, UIContentView {
    // UICollectionViewCell is used to leverage UIBackgroundConfiguration.
    private lazy var coverImageView: UICollectionViewCell = {
        let imageView = UICollectionViewCell()
        var configuration = UIBackgroundConfiguration.clear()
        configuration.backgroundColor = .secondarySystemFill
        configuration.cornerRadius = 8
        configuration.imageContentMode = .scaleAspectFill
        configuration.shadowProperties.radius = 8
        configuration.shadowProperties.opacity = 0.15
        configuration.shadowProperties.offset = CGSize(width: 0, height: 12)

        imageView.backgroundConfiguration = configuration
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()

    private lazy var authorsLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        return label
    }()

    var configuration: UIContentConfiguration {
        didSet {
            guard let configuration = configuration as? PopularMangaConfiguration else { return }
            configure(with: configuration)
        }
    }

    init(configuration: PopularMangaConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)

        preservesSuperviewLayoutMargins = true

        addSubview(coverImageView)
        addSubview(titleLabel)
        addSubview(authorsLabel)

        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorsLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            coverImageView.widthAnchor.constraint(equalTo: coverImageView.heightAnchor, multiplier: 0.7),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(
                equalToSystemSpacingAfter: coverImageView.trailingAnchor,
                multiplier: 1.5
            ),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            authorsLabel.firstBaselineAnchor.constraint(
                equalToSystemSpacingBelow: titleLabel.lastBaselineAnchor,
                multiplier: 1
            ),
            authorsLabel.leadingAnchor.constraint(
                equalToSystemSpacingAfter: coverImageView.trailingAnchor,
                multiplier: 1.5
            ),
            authorsLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
        ])

        configure(with: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with configuration: PopularMangaConfiguration) {
        titleLabel.text = configuration.title
        if let authors = configuration.authors {
            authorsLabel.isHidden = false
            authorsLabel.text = authors
        } else {
            authorsLabel.isHidden = true
        }

        alpha = configuration.isHighlighted ? 0.5 : 1

        var imageViewConfiguration = coverImageView.backgroundConfiguration
        imageViewConfiguration?.image = configuration.coverImage
        coverImageView.backgroundConfiguration = imageViewConfiguration
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    UIViewRepresenting {
        let configuration = PopularMangaConfiguration(
            title: """
            Taida na Akujoku Kizoku ni Tensei shita Ore, Scenario o \
            Bukkowashitara Kikakugai no Maryoku de Saikyou ni Natta
            """,
            authors: "Kikuchi Kousei, Odadouma"
        )

        return PopularMangaContentView(configuration: configuration)
    }
    .frame(width: .infinity, height: 200)
}
