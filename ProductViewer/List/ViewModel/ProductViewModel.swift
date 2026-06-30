//
//  ProductViewModel.swift
//  ProductViewer
//
//  Created by Jigs Sheth on 1/26/22.
//

import Foundation


protocol ProductViewModel  {
    func loadProducts() async
    func refreshProducts() async
}

@MainActor
@Observable
final class ProductViewModelImpl:ProductViewModel {
    
    //Below properties are observable, so it will publish the value and the state object into the view. The view will get notified.
    private(set) var productList:[Product] = []
    private(set) var lastErrorMessage: String?
    
    @ObservationIgnored
    private let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    /// Cache-first load: render local cache immediately, then refresh in background.
    func loadProducts() async {
        do {
            let cachedProducts = try await productRepository.loadProducts()
            applyIfChanged(cachedProducts)

        }catch {
            lastErrorMessage = "Failed to load products: \(error)"
        }
        await refreshProducts()
    }
    
    func refreshProducts() async {
        lastErrorMessage = nil
        let didChangeCache = await productRepository.refreshProducts()
        if didChangeCache {
            do{
                let productsFromCache = try await productRepository.loadProducts()
                applyIfChanged(productsFromCache)
            }catch {
                lastErrorMessage = "Failed to refresh products: \(error.localizedDescription)"
            }
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
