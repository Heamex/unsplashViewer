//
//  ProfileViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 16.04.23.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerDelegate: AnyObject {
	func fetchProfile(_ token:String, completion: @escaping (Result<Profile, Error>) -> Void)
}


final class ProfileViewController: UIViewController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		crateProfileImage()
		createNameLabel(name: "******** ********")
		createNicknameLabel(with: "@********")
		createUserInfoLabel(with: "")
		createExitButton()
		delegate = ProfileService()
		updateProfile(ProfileService.shared.profile)
		profileImageServiceObserver = NotificationCenter.default
			.addObserver(
				forName: ProfileImageService.DidChangeNotification,
				object: nil,
				queue: .main
			) { [weak self] _ in
				guard let self = self else { return }
				self.updateAvatar()
			}
		updateAvatar()
	}
	
	private func updateAvatar() {
		guard
			let profileImageUrl = ProfileImageService.shared.avatarURL,
			let url = URL(string: profileImageUrl)
		else { return }
		let processor = RoundCornerImageProcessor(cornerRadius: 70)
		imageView.kf.setImage(with: url, options: [.processor(processor)])
	}
	
	private var delegate: ProfileViewControllerDelegate?
	private var authToken = OAuth2TokenStorage().token
	private var splashViewController: SplashViewController?
	private var profileImageService = ProfileImageService.shared
	private var profileImageServiceObserver: NSObjectProtocol?
	
	private var imageView: UIImageView!
	private var nameLabel: UILabel!
	private var nickNameLabel: UILabel!
	private var userInfoLabel: UILabel!
	private var exitButton: UIButton!
	
	private func updateProfile(_ profile: Profile?) {
		guard let profile = profile else { return }
		self.nameLabel.text = profile.name
		self.nickNameLabel.text = profile.loginName
		self.userInfoLabel.text = profile.bio
	}
}
// 		MARK: - Верстка экрана
extension ProfileViewController {
	
	private func crateProfileImage() {
		let imageView = UIImageView(image: UIImage(named: "user_photo"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(imageView)
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
			imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			imageView.heightAnchor.constraint(equalToConstant: 70),
			imageView.widthAnchor.constraint(equalToConstant: 70)])
		self.imageView = imageView
	}
	
	private func createNameLabel(name: String) {
		let nameLabel = UILabel()
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.text = name
		view.addSubview(nameLabel)
		
		nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
		nameLabel.textColor = .white
		
		NSLayoutConstraint.activate([
			nameLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 8),
			nameLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
			nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)])
		self.nameLabel = nameLabel
	}
	
	private func createNicknameLabel(with nickname: String) {
		let nickNameLabel = UILabel()
		nickNameLabel.translatesAutoresizingMaskIntoConstraints = false
		nickNameLabel.text = nickname
		view.addSubview(nickNameLabel)
		
		nickNameLabel.font = UIFont.italicSystemFont(ofSize: 13)
		nickNameLabel.textColor = UIColor(named: "YP Gray")
		
		NSLayoutConstraint.activate([
			nickNameLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 8),
			nickNameLabel.leadingAnchor.constraint(equalTo: self.nameLabel.leadingAnchor),
			nickNameLabel .heightAnchor.constraint(equalToConstant: 20),
			nickNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
		])
		self.nickNameLabel = nickNameLabel
	}
	
	private func createUserInfoLabel(with info: String) {
		let userInfoLabel = UILabel()
		userInfoLabel.translatesAutoresizingMaskIntoConstraints = false
		userInfoLabel.text = info
		view.addSubview(userInfoLabel)
		
		userInfoLabel.font = UIFont.systemFont(ofSize: 13)
		userInfoLabel.textColor = .white
		
		NSLayoutConstraint.activate([
			userInfoLabel.topAnchor.constraint(equalTo: self.nickNameLabel.bottomAnchor, constant: 8),
			userInfoLabel.leadingAnchor.constraint(equalTo: self.nameLabel.leadingAnchor),
			userInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)])
		self.userInfoLabel = userInfoLabel
	}
	
	private func createExitButton() {
		let exitButton = UIButton()
		exitButton.translatesAutoresizingMaskIntoConstraints = false
		exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
		view.addSubview(exitButton)
		
		exitButton.setTitle("", for: .normal)
		exitButton.setImage(UIImage(named: "logout"), for: .normal)
		
		NSLayoutConstraint.activate([
			exitButton.widthAnchor.constraint(equalToConstant: 44),
			exitButton.heightAnchor.constraint(equalToConstant: 44),
			exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
			exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
												 constant: -16)])
		self.exitButton = exitButton
	}
	
	@objc private func exitButtonTapped() {
		print("попытка выхода засчитана")
	}
}
