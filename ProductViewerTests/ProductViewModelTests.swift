//
//  ProductViewModelTests.swift
//  ProductViewerTests
//
//  Created by Jigs on 6/29/26.
//

import XCTest
@testable import ProductViewer

@MainActor
final class ProductViewModelTests: XCTestCase {
    private var localStore: MockProductLocalStore!
    private var cloudService: MockProductCloudService!
    private var viewModel: ProductViewModelImpl!

    override func setUpWithError() throws {
        localStore = MockProductLocalStore()
        cloudService = MockProductCloudService()
        let repository = ProductRepositoryImpl(
            remoteService: cloudService,
            localStore: localStore
        )
        viewModel = ProductViewModelImpl(productRepository: repository)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        cloudService = nil
        localStore = nil
    }

    func testLoadProductsShowsCacheThenUpdatesAfterRefresh() async {
        let cachedProduct = ProductTestFixtures.product(
            id: 1,
            title: "Cached",
            updatedAt: Date(timeIntervalSince1970: 1000)
        )
        let refreshedProduct = ProductTestFixtures.product(
            id: 1,
            title: "Updated",
            updatedAt: Date(timeIntervalSince1970: 2000)
        )
        localStore.storedProducts = [cachedProduct]
        cloudService.productsToReturn = [refreshedProduct]
        cloudService.isFetchBlocked = true

        let loadTask = Task { await viewModel.loadProducts() }

        await waitUntil { !self.viewModel.productList.isEmpty }

        XCTAssertEqual(viewModel.productList.map(\.title), ["Cached"])

        cloudService.resumeFetch()
        await loadTask.value

        XCTAssertEqual(viewModel.productList.map(\.title), ["Updated"])
        XCTAssertNil(viewModel.lastErrorMessage)
    }

    func testLoadProductsWithEmptyCacheAndFailedRefreshSetsErrorMessage() async {
        cloudService.errorToThrow = ProductCloudServiceError.requestError

        await viewModel.loadProducts()

        XCTAssertTrue(viewModel.productList.isEmpty)
        XCTAssertEqual(
            viewModel.lastErrorMessage,
            "Unable to refresh products right now. Showing cached data when available."
        )
    }

    private func waitUntil(
        timeoutNanoseconds: UInt64 = 500_000_000,
        pollIntervalNanoseconds: UInt64 = 5_000_000,
        condition: @escaping () -> Bool
    ) async {
        let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds
        while DispatchTime.now().uptimeNanoseconds < deadline {
            if condition() {
                return
            }
            try? await Task.sleep(nanoseconds: pollIntervalNanoseconds)
        }
        XCTFail("Timed out waiting for condition")
    }
}
