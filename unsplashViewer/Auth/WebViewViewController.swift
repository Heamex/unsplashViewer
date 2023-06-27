//
//  WebViewViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 25.04.23.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
	func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
	func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
	
	private var estimatedProgressObservation: NSKeyValueObservation?
	@IBAction func didTapBackButton(_ sender: Any) {
		delegate?.webViewViewControllerDidCancel(self)
	}
	@IBOutlet private var webView: WKWebView!
	@IBOutlet private var progressView: UIProgressView!
	
	weak var delegate: WebViewViewControllerDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		estimatedProgressObservation = webView.observe(
			\.estimatedProgress,
			 options: [],
			 changeHandler: { [weak self] _, _ in
				 guard let self = self else { return }
				 self.updateProgress()
			 })
		
		var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)!
		urlComponents.queryItems = [
			URLQueryItem(name: "client_id", value: AccessKey),
			URLQueryItem(name: "redirect_uri", value: RedirectURI),
			URLQueryItem(name: "response_type", value: "code"),
			URLQueryItem(name: "scope", value: AccessScope)
		]
		let url = urlComponents.url!
		let request = URLRequest(url: url)
		webView.load(request)
		progressView.progress = 0.0
		
		webView.navigationDelegate = self
	}
	
	func updateProgress() {
		progressView.progress = Float(webView.estimatedProgress)
		progressView.isHidden = fabs(webView.estimatedProgress - 1) <= 0.0001
	}
	
}

extension WebViewViewController: WKNavigationDelegate {
	func webView(
		_ webView: WKWebView,
		decidePolicyFor navigationAction: WKNavigationAction,
		decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
	) {
		if let code = code(from: navigationAction) {
			delegate?.webViewViewController(self, didAuthenticateWithCode: code)
			decisionHandler(.cancel)
		} else {
			decisionHandler(.allow)
		}
	}
	
	private func code(from navigationAction: WKNavigationAction) -> String? {
		
		if
			let url = navigationAction.request.url,
			let urlComponents = URLComponents(string: url.absoluteString),
			urlComponents.path == "/oauth/authorize/native",
			let items = urlComponents.queryItems,
			let codeItem = items.first(where: { $0.name == "code" })
		{
			return codeItem.value
		} else {
			return nil
		}
	}
}
