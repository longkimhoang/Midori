//
//  LatestChapterUIView.swift
//  UI
//
//  Created by Long Kim on 24/12/24.
//

import UIKit

final class LatestChapterUIView: UIView, UIContentView {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()

    lazy var mangaLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    lazy var chapterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    lazy var groupLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    lazy var groupSymbolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.2.fill")
        imageView.tintColor = .secondaryLabel
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .subheadline)
        imageView.setContentHuggingPriority(.required, for: .horizontal)

        return imageView
    }()

    var configuration: any UIContentConfiguration {
        didSet {
            if let configuration = configuration as? LatestChapterUIConfiguration {
                configure(using: configuration)
            }
        }
    }

    init(configuration: LatestChapterUIConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)

        let contentLayoutGuide = UILayoutGuide()
        addLayoutGuide(contentLayoutGuide)
        NSLayoutConstraint.activate([
            contentLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            contentLayoutGuide.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            contentLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])

        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 10 / 7),
        ])

        addSubview(mangaLabel)
        addSubview(chapterLabel)
        addSubview(groupSymbolImageView)
        addSubview(groupLabel)
        NSLayoutConstraint.activate([
            mangaLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1),
            mangaLabel.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            mangaLabel.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            chapterLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1),
            chapterLabel.firstBaselineAnchor.constraint(
                equalToSystemSpacingBelow: mangaLabel.lastBaselineAnchor,
                multiplier: 1
            ),
            chapterLabel.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            groupSymbolImageView.leadingAnchor.constraint(
                equalToSystemSpacingAfter: imageView.trailingAnchor,
                multiplier: 1
            ),
            groupSymbolImageView.firstBaselineAnchor.constraint(equalTo: groupLabel.firstBaselineAnchor),
            groupLabel.leadingAnchor.constraint(equalTo: groupSymbolImageView.trailingAnchor, constant: 4),
            groupLabel.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            groupLabel.firstBaselineAnchor.constraint(
                equalToSystemSpacingBelow: chapterLabel.lastBaselineAnchor,
                multiplier: 1
            ),
        ])

        let heightConstraint = contentLayoutGuide.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true

        configure(using: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(using configuration: LatestChapterUIConfiguration) {
        imageView.image = configuration.coverImage
        mangaLabel.text = configuration.manga
        chapterLabel.text = configuration.chapter
        groupLabel.text = configuration.group
    }
}

struct LatestChapterUIConfiguration: Equatable {
    var manga: String = ""
    var chapter: String = ""
    var group: String = ""
    var coverImage: UIImage?
}

extension LatestChapterUIConfiguration: UIContentConfiguration {
    func makeContentView() -> any UIView & UIContentView {
        LatestChapterUIView(configuration: self)
    }

    func updated(for _: any UIConfigurationState) -> LatestChapterUIConfiguration {
        self
    }
}

final class LatestChapterCell: UICollectionViewCell {
    private var separatorHeightConstraint: NSLayoutConstraint!

    lazy var separatorLayoutGuide = UILayoutGuide()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addLayoutGuide(separatorLayoutGuide)

        let separatorLeadingConstraint = separatorLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor)
        separatorLeadingConstraint.priority = .defaultLow
        separatorLeadingConstraint.isActive = true

        let separatorTrailingConstraint = separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor)
        separatorTrailingConstraint.priority = .defaultLow
        separatorTrailingConstraint.isActive = true

        separatorHeightConstraint = separatorLayoutGuide.heightAnchor.constraint(equalToConstant: 1)
        separatorHeightConstraint.isActive = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()

        separatorHeightConstraint.constant = 1 / traitCollection.displayScale
    }
}

final class LatestChapterCellSeparatorView: UICollectionReusableView {
    lazy var separatorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        separatorView.backgroundColor = .separator
        addSubview(separatorView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
