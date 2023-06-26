//
//  URLSessionExtentoin.swift
//  unsplashViewer
//
//  Created by Nikita Belov on 24.06.23.
//

import UIKit

extension URLSession {

	func makeGenericError() -> Error {
		return NSError(domain: "Some objectTask error", code: 99)
	}
	
	func objectTask<T: Decodable> (
		for request: URLRequest,
		completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask
	{
		let fulfillCompletionOnMainThread: (Result<T, Error>) -> Void = { result in
			DispatchQueue.main.async {
				completion(result)
			}
		}
		
		let task = dataTask(with: request, completionHandler: { data, response, error in
			if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
				if 200 ..< 300 ~= statusCode {
					do {
						let decoder = JSONDecoder()
						let result = try decoder.decode(T.self, from: data)
						fulfillCompletionOnMainThread(.success(result))
					} catch {
						fulfillCompletionOnMainThread(.failure(error))
					}
					
				} else if let error = error {
					fulfillCompletionOnMainThread(.failure(error))
				} else {
					fulfillCompletionOnMainThread(.failure(self.makeGenericError()))
				}
			}
		})
		return task
	}
	
}
