//
//  SplashViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 10.05.23.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
	
	private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
	private let ShowGalleryScreenSegueIdentifier = "ShowGalleryScreen"
	private let oauth2Service = OAuth2Service()
	private let oauth2TokenStorage = OAuth2TokenStorage()
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if let token = oauth2TokenStorage.token {
			switchToTabBarController()
		} else {
			performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
		}
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setNeedsStatusBarAppearanceUpdate()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
	
	private func switchToTabBarController() {
		guard let window = UIApplication.shared.windows.first else {
			fatalError("Invalid Configuration") }
		let tabBarController = UIStoryboard(name: "Main", bundle: .main)
			.instantiateViewController(identifier: "TabBarViewController")
		window.rootViewController = tabBarController
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
			guard
				let navigationController = segue.destination as? UINavigationController,
				let viewController = navigationController.viewControllers[0] as? AuthViewController
			else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
			viewController.delegate = self
			navigationController.modalPresentationStyle = .fullScreen
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
}

extension SplashViewController: AuthViewControllerDelegate {
	func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
		ProgressHUD.show()
		dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			self.fetchOAuthToken(code)
		}
	}
	
	private func fetchOAuthToken(_ code: String) {
		oauth2Service.fetchOAuthToken(code) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let token):
				self.oauth2TokenStorage.token = token
				ProgressHUD.dismiss()
				self.switchToTabBarController()
			case .failure(let error):
				ProgressHUD.dismiss()
				// TODO [Sprint 11]
				break
			}
		}
	}
}
