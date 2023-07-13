//
//  TabBarController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 08.07.23.
//

import UIKit

final class TabBarController: UITabBarController {
	override func awakeFromNib() {
		super.awakeFromNib()
		let storyboard = UIStoryboard(name: "Main", bundle: .main)
		// Передаелать по примеру profileViewController
		let imagesListViewController = storyboard.instantiateViewController(
			withIdentifier: "ImagesListViewController"
		)
		
		let profileViewController = ProfileViewController()
		profileViewController.tabBarItem = UITabBarItem(
			title: nil,
			image: UIImage(named: "tab_profile_active"),
			selectedImage: nil)
		
		self.viewControllers = [imagesListViewController, profileViewController]
	}
}
