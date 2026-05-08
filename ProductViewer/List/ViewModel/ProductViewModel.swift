	//
	//  ProductViewModel.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/26/22.
	//

import Foundation


protocol ProductViewModel:ObservableObject  {
	func loadProducts() async
	func refreshProducts() async
}

@MainActor
final class ProductViewModelImpl:ProductViewModel {
	
	@Published private(set) var productList:[Product] = []
	@Published private(set) var lastErrorMessage: String?
	
	private let productRepository: ProductRepository
	
	init(productRepository: ProductRepository) {
		self.productRepository = productRepository
	}
	
	/// Cache-first load: render local cache immediately, then refresh in background.
	func loadProducts() async {
		let cachedProducts = await productRepository.loadCachedProducts()
		applyIfChanged(cachedProducts)
		
		await refreshProducts()
	}

	func refreshProducts() async {
		lastErrorMessage = nil
		let didChangeCache = await productRepository.refreshProductsFromRemote()
		if didChangeCache {
			let productsFromCache = await productRepository.getProducts()
			applyIfChanged(productsFromCache)
		} else if productList.isEmpty {
			// Offline and no cache case: keep graceful behavior with user-visible message.
			lastErrorMessage = "Unable to refresh products right now. Showing cached data when available."
		}
	}

	private func applyIfChanged(_ newProducts: [Product]) {
		if productList != newProducts {
			productList = newProducts
		}
	}
	
}
