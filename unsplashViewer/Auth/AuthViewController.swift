//
//  AuthViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 25.04.23.
//

import UIKit

final class AuthViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print(UserDefaults.standard.object(forKey: "OAuth2Token"))
	}
	
	let ShowWebViewSegueIdentifier: String = "ShowWebView"
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?){
		if segue.identifier == ShowWebViewSegueIdentifier {
			guard let webViewViewController = segue.destination as? WebViewViewController
			else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)") }
			webViewViewController.delegate = self
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
	
	@IBAction private func LogInButtonBressed(_ sender: Any) {
		
	}
}

extension AuthViewController: WebViewViewControllerDelegate {
	func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
			let oauth2Service = OAuth2Service()
			oauth2Service.fetchAuthToken(with: code) { result in
				switch result {
				case .success(let token):
					let tokenStorage = OAuth2TokenStorage()
					tokenStorage.token = token
				case .failure(let error):
					print("Failed to fetch auth token: \(error)")
				}
			}
		}

	func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
		dismiss(animated: true)
	}
}
