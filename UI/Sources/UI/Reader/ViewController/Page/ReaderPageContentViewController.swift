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
    private var imageLoadingTask: Task<Void, Error>?
    private var imageLoadingEvent: ImageTask.Event?
    private var previousLayoutSize: CGSize?

    @ViewLoading private var contentScrollView: UIScrollView
    @ViewLoading private var imageView: UIImageView

    let page: ReaderViewModel.Page
    private(set) lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()

    private lazy var isZoomedInSubject = PassthroughSubject<Bool, Never>()
    private(set) lazy var isZoomedInPublisher = isZoomedInSubject.eraseToAnyPublisher()

    init(page: ReaderViewModel.Page) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        imageLoadingTask?.cancel()
    }

    override func loadView() {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self

        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)

        let imageView = UIImageView()
        scrollView.addSubview(imageView)

        view = scrollView

        contentScrollView = scrollView
        self.imageView = imageView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageLoadingTask = Task {
            let request = ImageRequest(page: page)
            let imageTask = ImagePipeline.midoriReader.imageTask(with: request)

            for await event in imageTask.events {
                imageLoadingEvent = event
                // we're using contentUnavailableConfiguration to show loading and error states
                // so we need to update it whenever the image state changes
                setNeedsUpdateContentUnavailableConfiguration()

                switch event {
                case let .finished(.success(response)):
                    imageView.image = response.image
                    imageView.sizeToFit()
                    view.setNeedsLayout()
                default:
                    break
                }
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if case let .finished(.success(response)) = imageLoadingEvent, previousLayoutSize != view.bounds.size {
            let image = response.image
            let scaleX = view.bounds.width / image.size.width
            let scaleY = view.bounds.height / image.size.height
            let minScale = min(scaleX, scaleY)

            contentScrollView.minimumZoomScale = minScale
            contentScrollView.zoomScale = minScale

            imageView.center = view.center
            // We only need to do this setup once
            previousLayoutSize = view.bounds.size
        }
    }

    override func viewWillTransition(
        to _: CGSize,
        with coordinator: any UIViewControllerTransitionCoordinator
    ) {
        coordinator.animate { _ in
            self.updateImageViewOffset(in: self.contentScrollView)
        }
    }

    override func updateContentUnavailableConfiguration(using _: UIContentUnavailableConfigurationState) {
        switch imageLoadingEvent {
        case .finished(.success):
            contentUnavailableConfiguration = nil
        case .finished(.failure):
            var configuration = UIContentUnavailableConfiguration.empty()
            configuration.text = String(localized: "Failed to fatch image", bundle: .module)
            configuration.textProperties.font = .preferredFont(forTextStyle: .caption1)
            configuration.textProperties.color = .secondaryLabel
            contentUnavailableConfiguration = configuration
        case .progress, nil:
            var configuration = UIContentUnavailableConfiguration.loading()
            configuration.text = nil
            contentUnavailableConfiguration = configuration
        default:
            break
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

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with _: UIView?, atScale scale: CGFloat) {
        // scale is floating point so normal equality check is not reliable
        let isZoomedIn = !scale.isApproximatelyEqual(to: scrollView.minimumZoomScale)
        isZoomedInSubject.send(isZoomedIn)
    }
}

// MARK: - Private

private extension ReaderPageContentViewController {
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }

        let location = gesture.location(in: imageView)
        let zoomScale = if contentScrollView.zoomScale == contentScrollView.minimumZoomScale {
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

    func updateImageViewOffset(in scrollView: UIScrollView) {
        let height = imageView.bounds.height * scrollView.zoomScale
        let width = imageView.bounds.width * scrollView.zoomScale

        let deltaX = view.bounds.width - width
        let deltaY = view.bounds.height - height

        let offsetX = max(0, deltaX / 2)
        let offsetY = max(0, deltaY / 2)

        imageView.frame.origin = CGPoint(x: offsetX, y: offsetY)
    }
}
