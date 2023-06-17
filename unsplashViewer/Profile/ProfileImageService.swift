//
//  ProfileImageService.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 15.06.23.
//

import UIKit
import ProgressHUD

struct UserResult: Decodable {// структура, для хранения маленькой аватарки
	let profile_image: profileImage
	struct profileImage: Decodable {
		let small: String
	}
	func smallImage() -> String { self.profile_image.small }
}

final class ProfileImageService {
	
	static let shared = ProfileImageService()
	private let profileService = ProfileService.shared
	private (set) var avatarURL:String?
	private let session = URLSession.shared
	private var task: URLSessionTask?
	
	func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
		guard let token = OAuth2TokenStorage().token else { return }
		guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else { return }
		var request = URLRequest(url: url)
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "GET"
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
				let avatarStruct = try JSONDecoder().decode(UserResult.self, from: data)
				let avatarUrl = avatarStruct.smallImage()
				self.avatarURL = avatarUrl
				completion(.success(avatarUrl))
			}
			catch {
				completion(.failure(error))
			}
			
		}
		task.resume()
	}
	
}
