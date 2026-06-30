//
//  ProductViewModel.swift
//  ProductViewer
//
//  Created by Jigs Sheth on 1/26/22.
//

import Foundation

protocol ProductViewModel {
    var state: ProductListState { get }
    func loadProducts() async
    func refreshProducts() async
}

@MainActor
@Observable
final class ProductViewModelImpl: ProductViewModel {

    private(set) var productList: [Product] = []
    private(set) var lastErrorMessage: String?

    var state: ProductListState {
        ProductListState(products: productList, errorMessage: lastErrorMessage)
    }

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
        } catch {
            lastErrorMessage = UserMessages.cacheLoadFailed
        }
        await refreshProducts()
    }

    func refreshProducts() async {
        lastErrorMessage = nil
        let outcome = await productRepository.refreshProducts()

        switch outcome {
        case .updated:
            do {
                let productsFromCache = try await productRepository.loadProducts()
                applyIfChanged(productsFromCache)
            } catch {
                lastErrorMessage = UserMessages.cacheReloadFailed
            }
        case .unchanged:
            break
        case .failed(let failure):
            lastErrorMessage = failure.userMessage(hasCachedProducts: !productList.isEmpty)
        }
    }

    private func applyIfChanged(_ newProducts: [Product]) {
        if productList != newProducts {
            productList = newProducts
        }
    }
}
