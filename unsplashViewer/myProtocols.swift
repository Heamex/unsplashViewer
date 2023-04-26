//
//  myProtocols.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 26.04.23.
//

import Foundation

protocol WebViewViewControllerDelegate {
	func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
	func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
