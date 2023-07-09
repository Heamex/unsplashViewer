//
//  AuthViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 25.04.23.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
	func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
	private let ShowWebViewSegueIdentifier: String = "ShowWebView"
	weak var delegate: AuthViewControllerDelegate?
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == ShowWebViewSegueIdentifier {
			guard
				let webViewViewController = segue.destination as? WebViewViewController
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
		delegate?.authViewController(self, didAuthenticateWithCode: code)
	}

	func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
		dismiss(animated: true)
	}
}
