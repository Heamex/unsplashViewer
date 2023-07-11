//
//  AlertPresenter.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 11.07.23.
//

import UIKit

final class AlertPresenter {
	static let shared = AlertPresenter()
	
	func showAlert(on controller: UIViewController, with error: Error?) {
		var message = "Не удалось войти в систему"
		if let error = error {
			message = error.localizedDescription
		}
		
		let alertController = UIAlertController(
			title: "Что-то пошло не так(",
			message: message,
			preferredStyle: .alert
		)
		let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
			alertController.dismiss(animated: true, completion: nil)
		}
		
		alertController.addAction(okAction)
		
		controller.present(alertController, animated: true, completion: {return})
	}
}
