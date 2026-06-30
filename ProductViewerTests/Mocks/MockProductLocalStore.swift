//
//  MockProductLocalStore.swift
//  ProductViewerTests
//
//  Created by Jigs on 6/29/26.
//

import Foundation
@testable import ProductViewer

final class MockProductLocalStore: ProductLocalStore {
    var storedProducts: [Product]
    var loadError: Error?
    var saveError: Error?
    private(set) var saveCallCount = 0

    init(products: [Product] = []) {
        storedProducts = products
    }

    func loadProducts() throws -> [Product] {
        if let loadError {
            throw loadError
        }
        return storedProducts
    }

    func saveProducts(_ products: [Product]) throws {
        saveCallCount += 1
        if let saveError {
            throw saveError
        }
        storedProducts = products
    }
}
