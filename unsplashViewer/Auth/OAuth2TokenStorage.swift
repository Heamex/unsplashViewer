//
//  OAuth2TokenStorage.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 07.05.23.
//

import Foundation

class OAuth2TokenStorage {
	
	private let tokenKey = "OAuth2Token"
	
	var token: String? {
		get {
			return UserDefaults.standard.string(forKey: tokenKey)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: tokenKey)
			print("New token value is: \(newValue ?? "ERROR")")
		}
	}
}
