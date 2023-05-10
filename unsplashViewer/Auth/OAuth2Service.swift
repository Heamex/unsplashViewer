//
//  OAuth2Service.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 07.05.23.
//

import Foundation

class OAuth2Service {
	
	func fetchAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
		let urlString = "https://unsplash.com/oauth/token"
		guard let url = URL(string: urlString) else {
			completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
			return
		}
		
		var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
		components?.queryItems = [
			URLQueryItem(name: "client_id", value: AccessKey),
			URLQueryItem(name: "client_secret", value: SecretKey),
			URLQueryItem(name: "redirect_uri", value: RedirectURI),
			URLQueryItem(name: "code", value: code),
			URLQueryItem(name: "grant_type", value: "authorization_code")
		]
		
		guard let requestUrl = components?.url else {
			completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
			return
		}
		
		var request = URLRequest(url: requestUrl)
		request.httpMethod = "POST"
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard let httpResponse = response as? HTTPURLResponse,
				  (200...299).contains(httpResponse.statusCode),
				  let data = data else {
				completion(.failure(error ?? NSError(domain: "Unexpected error", code: -1, userInfo: nil)))
				return
			}
			
			do {
				let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
				let token = tokenResponse.accessToken
				
				DispatchQueue.main.async {
					let tokenStorage = OAuth2TokenStorage()
					tokenStorage.token = token
					completion(.success(token))
				}
			} catch {
				completion(.failure(error))
			}
		}.resume()
	}
}
