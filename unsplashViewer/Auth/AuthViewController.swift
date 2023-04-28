//
//  AuthViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 25.04.23.
//

import UIKit

final class AuthViewController: UIViewController {
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
		//TODO: process code
	}

	func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
		dismiss(animated: true)
	}
}
