//
//  OAuth2Service.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 07.05.23.
//

import Foundation

class OAuth2Service {
	
	private let urlSession = URLSession.shared
	private var task: URLSessionTask?
	private var lastCode: String?
	
	private func makeRequest(code: String) -> URLRequest? {
		let urlString = "https://unsplash.com/oauth/token"
		guard let url = URL(string: urlString) else {
			return nil
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
			return nil
		}
		
		var request = URLRequest(url: requestUrl)
		request.httpMethod = "POST"
		return request
	}
	
	func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
		assert(Thread.isMainThread)
		if lastCode == code { return }
		task?.cancel()
		lastCode = code
		
		guard let request = makeRequest(code: code) else {
			completion(.failure(NSError(domain: "Invalid URL", code: -1)))
			return
		}
		let task = urlSession.objectTask(for: request, completion: { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
			switch result {
			case .failure(let error):
					self?.lastCode = nil
				completion(.failure(NSError(domain: "Не удалось получить токен для входа. Ошибка: \n\(error)", code: -1)))
			case .success(let tokenResponse):
				let token: String = tokenResponse.accessToken
				OAuth2TokenStorage().token = token
				completion(.success(token))
			}
			self?.task = nil
		})
		self.task = task
		task.resume()
	}
	
}
//		let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
//		let token = tokenResponse.accessToken

