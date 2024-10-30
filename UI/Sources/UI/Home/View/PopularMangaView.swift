//
//  PopularMangaView.swift
//  UI
//
//  Created by Long Kim on 29/10/24.
//

import UIKit

struct PopularMangaConfiguration: Equatable {
    let title: String
    let authors: String?
    var opacity: CGFloat = 1
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
        updatedConfiguration.opacity = state.isHighlighted ? 0.5 : 1
        return updatedConfiguration
    }
}

final class PopularMangaContentView: UIView, UIContentView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 2
        return label
    }()

    private lazy var authorsLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
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

        addSubview(titleLabel)
        addSubview(authorsLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorsLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
            authorsLabel.firstBaselineAnchor.constraint(
                equalToSystemSpacingBelow: titleLabel.lastBaselineAnchor,
                multiplier: 1
            ),
            authorsLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            authorsLabel.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with configuration: PopularMangaConfiguration) {
        titleLabel.text = configuration.title
        if let authors = configuration.authors {
            authorsLabel.text = authors
        } else {
            authorsLabel.isHidden = true
        }

        alpha = configuration.opacity
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let configuration = PopularMangaConfiguration(
        title: """
        Taida na Akujoku Kizoku ni Tensei shita Ore, Scenario o \
        Bukkowashitara Kikakugai no Maryoku de Saikyou ni Natta
        """,
        authors: "Kikuchi Kousei, Odadouma"
    )

    return PopularMangaContentView(configuration: configuration)
}
