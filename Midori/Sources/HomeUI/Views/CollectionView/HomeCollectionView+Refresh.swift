//
//  HomeCollectionView+Refresh.swift
//
//
//  Created by Long Kim on 4/5/24.
//

import UIKit

extension HomeCollectionView.Coordinator {
  @objc func refresh(_ sender: UIRefreshControl) {
    Task { @MainActor in
      await store.send(.fetchHomeData).finish()
      sender.endRefreshing()
    }
  }
}
