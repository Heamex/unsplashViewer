//
//  SingleImageViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 17.04.23.
//

import UIKit

final class SingleImageViewController: UIViewController {
	
	
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
	}
	
}
