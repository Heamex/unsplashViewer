//
//  SingleImageViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 17.04.23.
//

import UIKit

final class SingleImageViewController: UIViewController {
	
	@IBOutlet private  var scrollView: UIScrollView!
	@IBOutlet private var ShareButton: UIButton!
	@IBAction private func didTapBackButton(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	@IBAction private func didTapShareButton(_ sender: Any) {
		let activityViewController = UIActivityViewController(activityItems: [imageView.image as Any], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}
	
	
	@IBOutlet private var imageView: UIImageView!
	
	private var mainViewController: UIViewController?
	var image: UIImage! {
		didSet {
			guard let image = image, isViewLoaded else { return }
			imageView.image = image
			rescaleAndCenterImageInScrollView(image: image)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageView.image = image
		ShareButton.layer.cornerRadius = 25
		mainViewController = ImagesListViewController()
		scrollView.minimumZoomScale = 0.1
		scrollView.maximumZoomScale = 1.25
		guard let image = image else { return }
		rescaleAndCenterImageInScrollView(image: image)
	}
	
	private func rescaleAndCenterImageInScrollView(image: UIImage) {
		let minZoomScale = scrollView.minimumZoomScale
		let maxZoomScale = scrollView.maximumZoomScale
		view.layoutIfNeeded()
		let visibleRectSize = scrollView.bounds.size
		let imageSize = image.size
		let hScale = visibleRectSize.width / imageSize.width
		let vScale = visibleRectSize.height / imageSize.height
		let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
		scrollView.setZoomScale(scale, animated: false)
		scrollView.layoutIfNeeded()
		let newContentSize = scrollView.contentSize
		let x = (newContentSize.width - visibleRectSize.width) / 2
		let y = (newContentSize.height - visibleRectSize.height) / 2
		scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
	}
	
}

extension SingleImageViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		imageView
	}
}
