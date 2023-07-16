//
//  SplashViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 10.05.23.
//

import UIKit
import ProgressHUD
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
	//MARK: - Private Properties
	private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
	private let ShowGalleryScreenSegueIdentifier = "ShowGalleryScreen"
	private let oauth2Service = OAuth2Service()
	private let oauth2TokenStorage = OAuth2TokenStorage()
	private let profileService = ProfileService.shared
	private let profileImageService = ProfileImageService.shared
	private var currentTask: URLSessionDataTask?
	private var splashLogoImage: UIImageView!
	
	//MARK: - Life Cycle
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		createSplashLogoImage(safeArea: view.safeAreaLayoutGuide)
		
		if let token = OAuth2TokenStorage().token {
			fetchProfile(token: token)
		} else {
			let main = UIStoryboard(name: "Main", bundle: .main)
			let authViewController: AuthViewController = main.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
			authViewController.delegate = self
			authViewController.modalPresentationStyle = .fullScreen
			self.present(authViewController, animated: true)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setNeedsStatusBarAppearanceUpdate()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
	
	// MARK: - Private Methods
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

//MARK: - createSplashLogo
extension SplashViewController {
	///Отрисовываем дубликат стартового Лого
	private func createSplashLogoImage(safeArea: UILayoutGuide) {
		view.backgroundColor = UIColor(named: "YP Black")
		splashLogoImage = UIImageView()
		splashLogoImage.image = UIImage(named: "Practicum_logo")
		splashLogoImage.contentMode = .scaleAspectFill
		splashLogoImage.clipsToBounds = true
		
		splashLogoImage.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(splashLogoImage)
		splashLogoImage.heightAnchor.constraint(equalToConstant: 75.11).isActive = true
		splashLogoImage.widthAnchor.constraint(equalToConstant: 72.52).isActive = true
		splashLogoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		splashLogoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
	}
}



extension SplashViewController: AuthViewControllerDelegate {
	
	func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
		dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			self.fetchOAuthToken(code)
		}
		UIBlockingProgressHUD.show()
	}
	
	private func fetchOAuthToken(_ code: String) {
		oauth2Service.fetchOAuthToken(code) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success (let token):
				self.fetchProfile(token: token)
			case .failure:
				self.showAlertViewController()
				break
			}
			UIBlockingProgressHUD.dismiss()
		}
	}
	
	private func fetchProfile(token: String) {
		profileService.fetchProfile(token) {[weak self] result in
			DispatchQueue.main.async {
				guard let self = self else {return}
				switch result {
				case .success (let result):
					self.profileImageService.fetchProfileImageURL(username: result.username) { _ in }
					self.switchToTabBarController()
				case .failure:
					self.showAlertViewController()
					break
				}
				UIBlockingProgressHUD.dismiss()
			}
		}
	}
	
	private func showAlertViewController() {
		let alertVC = UIAlertController(
			title: "Что-то пошло не так(",
			message: "Не удалось войти в систему",
			preferredStyle: .alert)
		let action = UIAlertAction(title: "Ok", style: .default)
		alertVC.addAction(action)
		present(alertVC, animated: true)
	}
}
