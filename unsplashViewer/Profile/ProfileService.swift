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
	
	private func requestForProfileInfo() -> URLRequest? { // Формируем запрос на получение данных профиля
		guard let authToken = authToken else {print("token is empty"); return nil }
		guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
		var request = URLRequest(url: url)
		request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "GET"
		return request
	}
	
	func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) { // Получаем данные профиля
		
		guard let request = requestForProfileInfo() else {
			completion(.failure(NSError(domain: "ошибка создания URLRequest", code: 0)))
			return
		}
		
		let task = urlSession.objectTask(for: request, completion: { [weak self] (result: Result<ProfileRowData,Error>) in
			
			switch result {
			case .success(let profileResponse):
				let profile = profileResponse.convertData()
				DispatchQueue.main.async {
					self?.profile = profile
				}
			case .failure(let error):
				print(error.localizedDescription)
			}
		})
		task.resume()
	}
	
}
