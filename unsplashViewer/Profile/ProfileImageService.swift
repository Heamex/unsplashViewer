//
//  ProfileImageService.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 15.06.23.
//

import UIKit
import ProgressHUD
import Kingfisher

struct UserResult: Decodable {// структура, для хранения маленькой аватарки
	let profile_image: profileImage
	struct profileImage: Decodable {
		let small: String
	}
	func smallImage() -> String { self.profile_image.small }
}

final class ProfileImageService {
	static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
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
		
		let urlSession = URLSession.shared
		let task = urlSession.objectTask(for: request, completion: { [weak self] (result: Result<UserResult, Error>) in
			switch result {
			case .success(let imageUrl):
				self?.avatarURL = imageUrl.smallImage()
				completion(.success(imageUrl.smallImage()))
			case .failure(let error):
				print("\(error.localizedDescription)")
				completion(.failure(error))
			}
		})
		
		task.resume()
	}
	
}

