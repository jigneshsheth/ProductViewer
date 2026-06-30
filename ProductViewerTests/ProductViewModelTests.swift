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

        await waitUntil { !self.viewModel.state.products.isEmpty }

        XCTAssertEqual(viewModel.state.products.map(\.title), ["Cached"])

        cloudService.resumeFetch()
        await loadTask.value

        XCTAssertEqual(viewModel.state.products.map(\.title), ["Updated"])
        XCTAssertNil(viewModel.state.errorMessage)
    }

    func testLoadProductsWithEmptyCacheAndFailedRefreshSetsLoadFailedMessage() async {
        cloudService.errorToThrow = ProductCloudServiceError.requestError

        await viewModel.loadProducts()

        XCTAssertTrue(viewModel.state.products.isEmpty)
        XCTAssertEqual(viewModel.state.errorMessage, UserMessages.loadFailedNoCache)
    }

    func testRefreshProductsWithCachedDataAndFailedRemoteSetsRefreshFailedMessage() async {
        let cachedProduct = ProductTestFixtures.product(id: 1, title: "Cached")
        localStore.storedProducts = [cachedProduct]
        cloudService.productsToReturn = [cachedProduct]

        await viewModel.loadProducts()
        cloudService.errorToThrow = ProductCloudServiceError.requestError

        await viewModel.refreshProducts()

        XCTAssertEqual(viewModel.state.products.map(\.title), ["Cached"])
        XCTAssertEqual(viewModel.state.errorMessage, UserMessages.refreshFailedWithCache)
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
