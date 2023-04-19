//
//  SingleImageViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 17.04.23.
//

import UIKit

final class SingleImageViewController: UIViewController {
	
	@IBOutlet var scrollView: UIScrollView!
	
	@IBAction func didTapBackButton(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	var image: UIImage! {
		didSet {
			guard isViewLoaded else { return }
			imageView.image = image
		}
	}
	
	@IBOutlet var imageView: UIImageView!
	var mainViewController: UIViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		imageView.image = image
		mainViewController = ImagesListViewController()
		scrollView.minimumZoomScale = 0.1
		scrollView.maximumZoomScale = 1.25
	}
	
}

extension SingleImageViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		imageView
	}
}
