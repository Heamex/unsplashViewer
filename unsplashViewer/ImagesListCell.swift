//
//  ImagesListCell.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 15.04.23.
//

import UIKit

final class ImagesListCell: UITableViewCell{
	static let reuseIdentifier = "ImagesListCell"
	@IBOutlet var likeButton: UIButton!
	@IBOutlet var dataLabel: UILabel!
	@IBOutlet var cellImage: UIImageView!
}
