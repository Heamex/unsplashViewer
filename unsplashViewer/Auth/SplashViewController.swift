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
	
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if let token = oauth2TokenStorage.token {
			UIBlockingProgressHUD.show()
			self.fetchProfile(token) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let profile):
					self .profileService.profile = profile
					self.switchToTabBarController()
				case .failure(let error):
					print(error.localizedDescription)
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
	
	
	
	func fetchProfile(_ token: String, completeon: @escaping (Result<Profile, Error>) -> Void) {
		
		guard let authToken = oauth2TokenStorage.token else {print("token is empty"); return}
		guard let url = URL(string: "https://api.unsplash.com/me") else { return }
		var request = URLRequest(url: url)
		request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "GET"
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			DispatchQueue.main.async {
				guard let httpResponse = response as? HTTPURLResponse else {
					UIBlockingProgressHUD.dismiss()
					completeon(.failure(error ?? NSError(domain: "There is no responce", code: 1, userInfo: nil)))
					return
				}
				guard let data = data else {
					UIBlockingProgressHUD.dismiss()
					completeon(.failure(error ?? NSError(domain: "There is no data", code: 4, userInfo: nil)))
					return
				}
				guard  (200...299).contains(httpResponse.statusCode) else {
					UIBlockingProgressHUD.dismiss()
					completeon(.failure(error ?? NSError(domain: "Bad status code.\nResponce is: \(httpResponse.statusCode)\n)", code: 2, userInfo: nil)))
					return
				}
				
				print()
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
						self.switchToTabBarController()
					case .failure(let error):
						print(error.localizedDescription)
						UIBlockingProgressHUD.dismiss()
					}
				}
			case .failure(let error):
				UIBlockingProgressHUD.dismiss()
				print(error.localizedDescription)
				// TODO [Sprint 11]
				break
			}
		}
	}
}
