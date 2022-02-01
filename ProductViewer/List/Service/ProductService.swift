	//
	//  ProductService.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/26/22.
	//

import Foundation

protocol ProductService {
	func fetchProducts() async throws -> [Product]
}

enum ProductServiceError: Error {
	case invalidUrl
	case invalidUrlRequest
	case dataParsingError
	case requestError
	case internalServerError
	case other
}

// Localized error for Product Service
extension ProductServiceError:LocalizedError {
	public var errorDescription: String? {
		switch self{
		case .invalidUrl:
			return NSLocalizedString("Invalid URL", comment: "Url is not valid.")
		case .invalidUrlRequest:
			return NSLocalizedString("Invalid URL request!", comment: "Invalid URL request!.")
		case .dataParsingError:
			return NSLocalizedString("Data Parsing error!", comment: "Data parsing error!.")
		case .requestError:
			return NSLocalizedString("Request error!", comment: "Request error!.")
		case .internalServerError:
			return NSLocalizedString("Internal Server error!", comment: "Server Internal error!.")
			
		case .other:
			return NSLocalizedString("Unknown error", comment: "Unknown Error.")
		}
	}
}


final class ProductServiceImpl:ProductService {
	
		/// Fetch Product
		/// - Returns: list of products in array
	func fetchProducts() async throws -> [Product] {
		guard let request = try buildURLRequest(from: APIConstants.dealsApiUrl) else {
			throw ProductServiceError.invalidUrlRequest
		}
		
		let (data,response) = try await URLSession.shared.data(for: request)
		guard let res = (response as? HTTPURLResponse) else {
			throw ProductServiceError.other
		}
		
		switch res.statusCode {
		case 400..<500:
			throw ProductServiceError.requestError
		case 500..<600:
			throw ProductServiceError.internalServerError
		default:
			print("Successful Request")
		}
		
		do {
			let products = try JSONDecoder().decode(Products.self, from: data)
			return products.products
		}
		catch {
			throw error
		}
	}
	
		/// Build Request URL
		/// - Parameter urlString: url String
		/// - Returns: Optional URL request
	private func buildURLRequest(from urlString:String) throws -> URLRequest? {
		guard let url = URL(string:urlString ) else {
			throw ProductServiceError.invalidUrl
		}
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
			// set any custom header values for request
		return request
	}
	
}
