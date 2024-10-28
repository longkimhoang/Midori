//
//  HomeSectionHeaderButtonView.swift
//  UI
//
//  Created by Long Kim on 29/10/24.
//

import UIKit

final class HomeSectionHeaderButtonView: UICollectionReusableView {
    var label: String = "" {
        didSet {
            button.configuration = .homeSectionHeader(label: label)
        }
    }

    var actionHandler: (() -> Void)?

    private lazy var button = UIButton(
        primaryAction: UIAction { [unowned self] _ in
            actionHandler?()
        }
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        button.configurationUpdateHandler = { button in
            button.alpha = button.state == .highlighted ? 0.5 : 1
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        button.alpha = 1
    }
}

private extension UIButton.Configuration {
    static func homeSectionHeader(label: String) -> Self {
        let symbolConfiguration = UIImage.SymbolConfiguration(hierarchicalColor: .secondaryLabel)
            .applying(UIImage.SymbolConfiguration(textStyle: .title2))

        var configuration: Self = .plain()
        configuration.baseForegroundColor = .label
        configuration.attributedTitle = AttributedString(
            label,
            attributes: AttributeContainer().font(.preferredFont(forTextStyle: .title1))
        )
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        configuration.preferredSymbolConfigurationForImage = symbolConfiguration
        configuration.image = UIImage(systemName: "chevron.right")
        configuration.titleAlignment = .leading

        return configuration
    }
}

#Preview {
    let view = HomeSectionHeaderButtonView()
    view.label = "A button"
    view.actionHandler = {
        print("Button pressed")
    }

    return view
}
