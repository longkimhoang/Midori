//
//  HomeViewController+ImageFetching.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Nuke
import UIKit

extension HomeViewController {
    func cachedCoverImage(for itemIdentifier: ItemIdentifier) -> UIImage? {
        let request = imageRequest(for: itemIdentifier)
        return request.flatMap { ImagePipeline.midoriApp.cache.cachedImage(for: $0)?.image }
    }

    func fetchCoverImage(for itemIdentifier: ItemIdentifier) {
        guard let request = imageRequest(for: itemIdentifier) else {
            return
        }

        Task(priority: .userInitiated) {
            let image = try await ImagePipeline.midoriApp.image(for: request)
            coverImageDominantColors[itemIdentifier] = await computeDominantColor(for: image, context: context)
            reconfigureItems(with: [itemIdentifier])
        }
    }

    nonisolated func computeDominantColor(
        for image: UIImage,
        context: CIContext
    ) async -> UIColor? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }

        let filter = CIFilter.areaAverage()
        filter.extent = ciImage.extent
        filter.inputImage = ciImage

        guard let outputImage = filter.outputImage else {
            return nil
        }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: outputImage.extent,
            format: .RGBA8,
            colorSpace: outputImage.colorSpace
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255.0,
            green: CGFloat(bitmap[1]) / 255.0,
            blue: CGFloat(bitmap[2]) / 255.0,
            alpha: CGFloat(bitmap[3]) / 255.0
        )
    }

    private func imageRequest(for itemIdentifier: ItemIdentifier) -> ImageRequest? {
        switch itemIdentifier {
        case let .popularManga(id):
            let manga = viewModel.data.popularMangas[id: id]
            return ImageRequest(url: manga?.coverImageURL, processors: [.resize(height: 180)])
        case let .latestChapter(id):
            let chapter = viewModel.data.latestChapters[id: id]
            return ImageRequest(url: chapter?.coverImageURL, processors: [.resize(width: 60)])
        case let .recentlyAddedManga(id):
            let manga = viewModel.data.recentlyAddedMangas[id: id]
            return ImageRequest(url: manga?.coverImageURL, processors: [.resize(height: 128)])
        }
    }
}

extension HomeViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let imageRequests = imageRequests(for: indexPaths)
        imagePrefetcher.startPrefetching(with: imageRequests)
    }

    func collectionView(_: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let imageRequests = imageRequests(for: indexPaths)
        imagePrefetcher.stopPrefetching(with: imageRequests)
    }

    private func imageRequests(for indexPaths: [IndexPath]) -> [ImageRequest] {
        indexPaths.compactMap {
            let itemIdentifier = dataSource.itemIdentifier(for: $0)
            return itemIdentifier.flatMap(imageRequest)
        }
    }
}
