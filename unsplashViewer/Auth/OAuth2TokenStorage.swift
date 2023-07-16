//
//  OAuth2TokenStorage.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 07.05.23.
//

import Foundation
import SwiftKeychainWrapper

class OAuth2TokenStorage {
	
	private let tokenKey: String? = nil
	
	var token: String? {
		get {
			let tokenFromKeychain: String? = KeychainWrapper.standard.string(forKey: "Auth token")
			print("** token has been taken **")
			return tokenFromKeychain
		}
		set {
			if let newValue = newValue {
				let saveSuccessful: Bool = KeychainWrapper.standard.set(newValue, forKey: "Auth token")
				if saveSuccessful {
					print("** token saved! **")
				} else {
					print("** error token saving! **")
				}
			} else {
				KeychainWrapper.standard.remove(forKey: "Auth token")
				print(" ** Токен удалён **")
			}
			
		}
	}
}
