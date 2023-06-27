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
	private let profileService = ProfileService.shared
	private let profileImageService = ProfileImageService.shared
	
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if let token = oauth2TokenStorage.token {
			UIBlockingProgressHUD.show()
			self.fetchProfile(token) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let profileData):
					self.profileService.profile = profileData
					var username = profileData.loginName
					username.removeFirst()
					profileImageService.fetchProfileImageURL(username: username) { _ in }
					self.switchToTabBarController()
				case .failure(let error):
					self.showAlert(with: error)
					UIBlockingProgressHUD.dismiss()
				}
			}

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
	
	private func switchToTabBarController() {
		guard let window = UIApplication.shared.windows.first else {
			fatalError("Invalid Configuration") }
		let tabBarController = UIStoryboard(name: "Main", bundle: .main)
			.instantiateViewController(identifier: "TabBarViewController")
		window.rootViewController = tabBarController
	}
	
	func showAlert(with error: Error?) {
		var message = "Не удалось войти в систему"
		var isAdvancedAlertMode = true
		
		if let error = error {
			guard isAdvancedAlertMode else { return }
			message = error.localizedDescription
		}
		
		let alertController = UIAlertController(
			title: "Что-то пошло не так(",
			message: message,
			preferredStyle: .alert
		)
		let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
			alertController.dismiss(animated: true, completion: nil)
		}
		
		alertController.addAction(okAction)
		
		present(alertController, animated: true, completion: nil)
	}

}



extension SplashViewController: AuthViewControllerDelegate {
	
	func fetchProfile(_ token: String, completeon: @escaping (Result<Profile, Error>) -> Void) {
		
		guard let url = URL(string: "https://api.unsplash.com/me") else { return }
		var request = URLRequest(url: url)
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "GET"
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			DispatchQueue.main.async {
				guard let httpResponse = response as? HTTPURLResponse else {
					UIBlockingProgressHUD.dismiss()
					self.showAlert(with: error)
					completeon(.failure(error ?? NSError(domain: "There is no responce", code: 1, userInfo: nil)))
					return
				}
				guard let data = data else {
					UIBlockingProgressHUD.dismiss()
					self.showAlert(with: error)
					completeon(.failure(error ?? NSError(domain: "There is no data", code: 4, userInfo: nil)))
					return
				}
				guard  (200...299).contains(httpResponse.statusCode) else {
					UIBlockingProgressHUD.dismiss()
					self.showAlert(with: error)
					completeon(.failure(error ?? NSError(domain: "Bad status code.\nResponce is: \(httpResponse.statusCode)\n)", code: 2, userInfo: nil)))
					return
				}
				do {
					let profileResponse = try JSONDecoder().decode(ProfileRowData.self, from: data)
					let profile = profileResponse.convertData()
					DispatchQueue.main.async {
						UIBlockingProgressHUD.dismiss()
						completeon(.success(profile))
					}
				}
				catch {
					UIBlockingProgressHUD.dismiss()
					self.showAlert(with: error)
					completeon(.failure(error))
				}
			}
		}
		task.resume()
	}
	
	
	func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
		UIBlockingProgressHUD.show()
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
				self.fetchProfile(token) { [weak self] result in
					guard let self = self else { return }
					switch result {
					case .success(let profileData):
						self.profileService.profile = profileData
						let username = profileData.loginName
						ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
						self.switchToTabBarController()
					case .failure(let error):
						self.showAlert(with: error)
						UIBlockingProgressHUD.dismiss()
					}
				}
			case .failure(let error):
				UIBlockingProgressHUD.dismiss()
				self.showAlert(with: error)
				break
			}
		}
	}
}
