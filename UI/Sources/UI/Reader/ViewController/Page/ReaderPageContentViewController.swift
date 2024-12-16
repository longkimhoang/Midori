//
//  ReaderPageContentViewController.swift
//  UI
//
//  Created by Long Kim on 25/11/24.
//

import Combine
import MidoriViewModels
import Nuke
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

    @Published var imageLoadingEvent: ImageTask.Event?
    var onRetryImageLoading: (() -> Void)?

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

        cancellable = $imageLoadingEvent
            .sink { [unowned self] event in
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        cancellable = nil
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if case let .finished(.success(response)) = imageLoadingEvent, previousLayoutSize != view.bounds.size {
            let image = response.image
            let scaleX = view.bounds.width / image.size.width
            let scaleY = view.bounds.height / image.size.height
            let minScale = min(scaleX, scaleY)

            if minScale >= 1 {
                contentScrollView.maximumZoomScale = minScale * 1.5
            }

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

    override var contentUnavailableConfigurationState: UIContentUnavailableConfigurationState {
        var state = super.contentUnavailableConfigurationState
        switch imageLoadingEvent {
        case .finished(.success):
            state.imageLoadingState = .success
        case let .finished(.failure(error)):
            state.imageLoadingState = .failure(error.localizedDescription)
        case .progress, nil:
            state.imageLoadingState = .loading
        default:
            break
        }

        return state
    }

    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        switch state.imageLoadingState {
        case .success:
            contentUnavailableConfiguration = nil
        case let .failure(message):
            var configuration = UIContentUnavailableConfiguration.empty()
            configuration.text = String(localized: "Failed to fatch image", bundle: .module)
            configuration.secondaryText = message
            configuration.button.title = String(localized: "Retry", bundle: .module)
            configuration.buttonProperties.primaryAction = UIAction { [unowned self] _ in
                onRetryImageLoading?()
            }
            contentUnavailableConfiguration = configuration
        case .loading:
            var configuration = UIContentUnavailableConfiguration.loading()
            configuration.text = nil
            contentUnavailableConfiguration = configuration
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

private extension UIConfigurationStateCustomKey {
    static let imageLoadingState = UIConfigurationStateCustomKey("com.midori.imageLoadingState")
}

private extension UIContentUnavailableConfigurationState {
    enum ImageLoadingState: Hashable {
        case loading
        case failure(String)
        case success
    }

    var imageLoadingState: ImageLoadingState {
        get { self[.imageLoadingState] as? ImageLoadingState ?? .loading }
        set { self[.imageLoadingState] = newValue }
    }
}
