//
//  ViewController.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 22.03.23.
//

import UIKit

class ImagesListViewController: UIViewController {

	@IBOutlet var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
	}
	
	private let photosName :[String] = Array(0..<20).map{"\($0)"}
	
	private lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		return formatter
	}()
	
//	MARK: - Собираем ячейку
	
	func configCell(for cell: ImagesListCell, at indexPath: IndexPath) {
		let imageName = photosName[indexPath.row]
		
		guard let image = UIImage(named: imageName) else {
			return
		}
		if indexPath.row.isMultiple(of: 2) {
			cell.likeButton.setImage(UIImage(named: "likeNoActive"), for: .normal)
		} else {
			cell.likeButton.setImage(UIImage(named: "likeIsActive"), for: .normal)
		}
		
		cell.imageView!.image = image
		cell.dataLabel.text = dateFormatter.string(from: Date(timeIntervalSinceNow: 0))
	}


}

extension ImagesListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}
}

extension ImagesListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return photosName.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
			
			guard let imageListCell = cell as? ImagesListCell else {
				return UITableViewCell()
			}
			
			configCell(for: imageListCell, at: indexPath)
			return imageListCell
		}
	
	
}
