//
//  WebViewViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 25.04.23.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
	
	@IBAction func didTapBackButton(_ sender: Any) {
		dismiss(animated: true)
	}
	@IBOutlet private var webView: WKWebView!
}
