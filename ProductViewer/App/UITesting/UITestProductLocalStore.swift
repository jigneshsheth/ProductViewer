//
//  UITestProductLocalStore.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//

import Foundation

final class UITestProductLocalStore: ProductLocalStore {
    private var products: [Product]

    init(products: [Product] = ProductUITestFixtures.products) {
        self.products = products
    }

    func loadProducts() throws -> [Product] {
        products
    }

    func saveProducts(_ products: [Product]) throws {
        self.products = products
    }
}
