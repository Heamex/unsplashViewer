import UIKit

class ImagesListViewController: UIViewController {
	
	@IBOutlet private var tableView: UITableView!
	//	let gradientLayer = CAGradientLayer()
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	private let photosName :[String] = Array(0..<20).map{"\($0)"}
	
	private lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		return formatter
	}()
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
	
	func configCell(for cell: ImagesListCell, at indexPath: IndexPath) {
		let imageName = photosName[indexPath.row]
		
		guard let image = UIImage(named: imageName) else {
			return
		}
		
		cell.cellImage.image = image
		cell.dataLabel.text = dateFormatter.string(from: Date())
		if indexPath.row.isMultiple(of: 2) {
			cell.likeButton.setImage(UIImage(named: "likeNoActive"), for: .normal)
		} else {
			cell.likeButton.setImage(UIImage(named: "likeIsActive"), for: .normal)
		}
		
		cell.cellImage.layer.cornerRadius = 16
		
		// MARK: - Этот код и это недоделанный градиент. В будущем уберу этот код или заставлю его работать.
		//		gradientLayer.colors = [UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0).cgColor, UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1).cgColor]
		//		gradientLayer.frame = CGRect(x: 0, y: image.size.height - 30, width: image.size.width, height: 30)
		//
		//		cell.cellImage.layer.addSublayer(gradientLayer)
	}
	
}

extension ImagesListViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let image = UIImage(named: photosName[indexPath.row]) else {
			return 0
		}
		let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
		let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
		let imageWidth = image.size.width
		let scale = imageViewWidth / imageWidth
		let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
		return cellHeight
	}
}
