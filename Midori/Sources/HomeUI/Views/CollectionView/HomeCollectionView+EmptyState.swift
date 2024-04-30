//
//  HomeCollectionView+EmptyState.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import UIKit

extension HomeCollectionView.ViewController {
  override func updateContentUnavailableConfiguration(
    using state: UIContentUnavailableConfigurationState
  ) {
    switch coordinator.store.withState(\.fetchStatus) {
    case .success:
      contentUnavailableConfiguration = nil
    case .pending:
      let configuration = UIContentUnavailableConfiguration.loading().updated(for: state)
      contentUnavailableConfiguration = configuration
    case let .failure(reason: reason):
      var configuration = UIContentUnavailableConfiguration.empty().updated(for: state)
      configuration.image = UIImage(
        systemName: "network.slash",
        compatibleWith: state.traitCollection
      )
      configuration.text = "Cannot retrieve content"
      configuration.secondaryText = reason

      var retryButtonConfiguration = UIButton.Configuration.borderless()
      retryButtonConfiguration.title = "Retry"
      configuration.button = retryButtonConfiguration
      configuration.buttonProperties.primaryAction = UIAction { [weak self] _ in
        self?.coordinator.store.send(.fetchHomeData)
      }

      contentUnavailableConfiguration = configuration
    }
  }
}
