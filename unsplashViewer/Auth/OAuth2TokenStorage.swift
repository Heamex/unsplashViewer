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
			print("Token key has been taken: \(UserDefaults.standard.string(forKey: tokenKey) ?? "ERROR")")
			return UserDefaults.standard.string(forKey: tokenKey)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: tokenKey)
			print("New token key is: \(newValue ?? "ERROR")")
		}
	}
}
