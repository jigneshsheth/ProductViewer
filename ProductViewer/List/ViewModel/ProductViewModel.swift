	//
	//  ProductViewModel.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/26/22.
	//

import Foundation


protocol ProductViewModel:ObservableObject  {
	func loadProducts() async throws
}

@MainActor
final class ProductViewModelImpl:ProductViewModel {
	
	@Published private(set) var productList:[Product] = []
	
	private let productService: ProductService
	
	init(productService:ProductService) {
		self.productService = productService
	}
	
		/// loading Product data
	func loadProducts() async throws{
		self.productList = try await productService.fetchProducts()
	}
	
}
