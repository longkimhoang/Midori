//
//  ReaderPageContentViewController.swift
//  UI
//
//  Created by Long Kim on 25/11/24.
//

import Combine
import MidoriViewModels
import Nuke
import Numerics
import SnapKit
import UIKit

final class ReaderPageContentViewController: UIViewController {
    private var cancellable: AnyCancellable?
    private var previousLayoutSize: CGSize?

    @ViewLoading private var contentScrollView: UIScrollView
    @ViewLoading private var imageView: UIImageView

    let page: ReaderViewModel.Page
    private(set) lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()

    @Published var image: UIImage?

    init(page: ReaderViewModel.Page) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self

        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)

        let imageView = UIImageView()
        scrollView.addSubview(imageView)

        view = scrollView

        contentScrollView = scrollView
        self.imageView = imageView
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        loadImage()
    }

    override func viewWillTransition(
        to _: CGSize,
        with coordinator: any UIViewControllerTransitionCoordinator
    ) {
        coordinator.animate { _ in
            self.updateImageViewOffset(in: self.contentScrollView)
        }
    }
}

extension ReaderPageContentViewController: UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateImageViewOffset(in: scrollView)
    }
}

// MARK: - Private

extension ReaderPageContentViewController {
    private func loadImage() {
        let request = ImageRequest(page: page)
        cancellable = ImagePipeline.midoriReader.imagePublisher(with: request)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    var configuration = UIContentUnavailableConfiguration.loading()
                    configuration.text = nil
                    self?.contentUnavailableConfiguration = configuration
                }
            )
            .sink { [weak self] completion in
                guard let self else {
                    return
                }
                switch completion {
                case let .failure(error):
                    var configuration = UIContentUnavailableConfiguration.empty()
                    configuration.text = String(localized: "Failed to fatch image", bundle: .module)
                    configuration.secondaryText = error.localizedDescription
                    configuration.button.title = String(localized: "Retry", bundle: .module)
                    configuration.buttonProperties.primaryAction = UIAction { [unowned self] _ in
                        loadImage()
                    }
                    contentUnavailableConfiguration = configuration
                case .finished:
                    break
                }
            } receiveValue: { [weak self] response in
                guard let self else {
                    return
                }

                guard imageView.image != response.image else {
                    contentUnavailableConfiguration = nil
                    return
                }

                imageView.image = response.image
                imageView.sizeToFit()
                let image = response.image
                let scaleX = view.frame.width / image.size.width
                let scaleY = view.frame.height / image.size.height
                let minScale = min(scaleX, scaleY)

                if minScale >= 1 {
                    contentScrollView.maximumZoomScale = minScale * 1.5
                }

                contentScrollView.minimumZoomScale = minScale
                contentScrollView.zoomScale = minScale

                imageView.center = view.center
                contentUnavailableConfiguration = nil
            }
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }

        let location = gesture.location(in: imageView)
        let zoomScale =
            if contentScrollView.zoomScale == contentScrollView.minimumZoomScale {
                contentScrollView.maximumZoomScale
            } else {
                contentScrollView.minimumZoomScale
            }

        let width = contentScrollView.frame.width / zoomScale
        let height = contentScrollView.frame.height / zoomScale
        let x = location.x - width / 2
        let y = location.y - height / 2

        contentScrollView.zoom(to: CGRect(x: x, y: y, width: width, height: height), animated: true)
    }

    private func updateImageViewOffset(in scrollView: UIScrollView) {
        let height = imageView.bounds.height * scrollView.zoomScale
        let width = imageView.bounds.width * scrollView.zoomScale

        let deltaX = view.bounds.width - width
        let deltaY = view.bounds.height - height

        let offsetX = max(0, deltaX / 2)
        let offsetY = max(0, deltaY / 2)

        imageView.frame.origin = CGPoint(x: offsetX, y: offsetY)
    }
}
