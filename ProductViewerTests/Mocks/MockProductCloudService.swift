//
//  MockProductCloudService.swift
//  ProductViewerTests
//
//  Created by Jigs on 6/29/26.
//

import Foundation
@testable import ProductViewer

final class MockProductCloudService: ProductCloudService {
    var productsToReturn: [Product] = []
    var errorToThrow: Error?
    private(set) var fetchCallCount = 0

    private var fetchGate: CheckedContinuation<Void, Never>?
    var isFetchBlocked = false

    func fetchProducts() async throws -> [Product] {
        fetchCallCount += 1
        if isFetchBlocked {
            await withCheckedContinuation { continuation in
                fetchGate = continuation
            }
        }
        if let errorToThrow {
            throw errorToThrow
        }
        return productsToReturn
    }

    func resumeFetch() {
        fetchGate?.resume()
        fetchGate = nil
    }
}
