//
//  ReaderPageContentViewController.swift
//  UI
//
//  Created by Long Kim on 25/11/24.
//

import MidoriViewModels
import Nuke
import SnapKit
import UIKit

final class ReaderPageContentViewController: UIViewController {
    private var imageLoadingTask: Task<Void, Error>?
    private var imageLoadingEvent: ImageTask.Event?
    private var didPerformInitialLayout: Bool = false

    @ViewLoading private var contentScrollView: UIScrollView
    @ViewLoading private var imageView: UIImageView

    let page: ReaderViewModel.Page

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

        if case .finished(.success) = imageLoadingEvent, !didPerformInitialLayout {
            let scaleX = view.bounds.width / imageView.frame.width
            let scaleY = view.bounds.height / imageView.frame.height
            let minScale = min(scaleX, scaleY)

            contentScrollView.minimumZoomScale = minScale
            contentScrollView.zoomScale = minScale

            imageView.center = view.center
            // We only need to do this setup once
            didPerformInitialLayout = true
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
        let height = imageView.bounds.height * scrollView.zoomScale
        let width = imageView.bounds.width * scrollView.zoomScale

        let deltaX = view.bounds.width - width
        let deltaY = view.bounds.height - height

        let offsetX = max(0, deltaX / 2)
        let offsetY = max(0, deltaY / 2)

        imageView.frame.origin = CGPoint(x: offsetX, y: offsetY)
    }
}
