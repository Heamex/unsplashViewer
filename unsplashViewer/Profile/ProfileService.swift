//
//  ProfileService.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 28.05.23.
//

import Foundation

struct ProfileRowData: Codable { // структура, в которую собираются данные о профиле из json.
	let username: String
	let first_name: String
	let last_name: String?
	let bio: String?
	
	func convertData() -> Profile{
		var name: String
		var loginName: String
		var bio: String?
		
		if let newBio = self.bio { bio = newBio }
		else { bio = "" }
		
		if let last_name = self.last_name { name = "\(self.first_name) \(last_name)" }
		else { name = self.first_name }
		
		loginName = "@\(self.username)"
		
		let newData = Profile(name: name, loginName: loginName, bio: bio)
		return newData
	}
}

struct Profile { // структура, данные из которых заносятся в текстовые поля профиля
	let name: String
	let loginName: String
	let bio: String?
}


final class ProfileService: ProfileViewControllerDelegate {
	static let shared = ProfileService()
	private let urlSession = URLSession.shared
	private var task: URLSessionTask?
	private let authToken = OAuth2TokenStorage().token
	var profile: Profile?
	
	
	func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
		
		guard let authToken = authToken else {print("token is empty"); return}
		guard let url = URL(string: "https://api.unsplash.com/me") else { return }
		var request = URLRequest(url: url)
		request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "GET"
		
		let task = urlSession.dataTask(with: request) { data, response, error in
				guard let httpResponse = response as? HTTPURLResponse else {
					completion(.failure(error ?? NSError(domain: "There is no responce", code: 1, userInfo: nil)))
					return
				}
				guard let data = data else {
					completion(.failure(error ?? NSError(domain: "There is no data", code: 4, userInfo: nil)))
					return
				}
				guard  (200...299).contains(httpResponse.statusCode) else {
					completion(.failure(error ?? NSError(domain: "Bad status code.\nResponce is: \(httpResponse.statusCode)\n)", code: 2, userInfo: nil)))
					return
				}
				
				do {
					let profileResponse = try JSONDecoder().decode(ProfileRowData.self, from: data)
					let profile = profileResponse.convertData()
					DispatchQueue.main.async {
						completion(.success(profile))
					}
				}
				catch {
					completion(.failure(error))
				}
				self.task = nil
		}
		task.resume()
	}
	
}
