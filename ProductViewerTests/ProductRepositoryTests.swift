//
//  ProductRepositoryTests.swift
//  ProductViewerTests
//
//  Created by Jigs on 6/29/26.
//

import XCTest
@testable import ProductViewer

final class ProductRepositoryTests: XCTestCase {
    private var localStore: MockProductLocalStore!
    private var cloudService: MockProductCloudService!
    private var repository: ProductRepositoryImpl!

    override func setUpWithError() throws {
        localStore = MockProductLocalStore()
        cloudService = MockProductCloudService()
        repository = ProductRepositoryImpl(
            remoteService: cloudService,
            localStore: localStore
        )
    }

    override func tearDownWithError() throws {
        repository = nil
        cloudService = nil
        localStore = nil
    }

    func testLoadProductsDeduplicatesDuplicateIDsByNewestUpdatedAt() async throws {
        let older = ProductTestFixtures.product(
            id: 1,
            title: "Older",
            updatedAt: Date(timeIntervalSince1970: 1000)
        )
        let newer = ProductTestFixtures.product(
            id: 1,
            title: "Newer",
            updatedAt: Date(timeIntervalSince1970: 2000)
        )
        localStore.storedProducts = [older, newer, ProductTestFixtures.product(id: 2, title: "Other")]

        let products = try await repository.loadProducts()

        XCTAssertEqual(products.count, 2)
        XCTAssertEqual(products.first(where: { $0.id == 1 })?.title, "Newer")
    }

    func testRefreshProductsUsesNewestRemoteVersionForDuplicateIDs() async {
        let olderRemote = ProductTestFixtures.product(
            id: 1,
            title: "Remote Older",
            updatedAt: Date(timeIntervalSince1970: 1000)
        )
        let newerRemote = ProductTestFixtures.product(
            id: 1,
            title: "Remote Newer",
            updatedAt: Date(timeIntervalSince1970: 2000)
        )
        cloudService.productsToReturn = [olderRemote, newerRemote, ProductTestFixtures.product(id: 2)]

        let didChange = await repository.refreshProducts()

        XCTAssertTrue(didChange)
        XCTAssertEqual(localStore.storedProducts.count, 2)
        XCTAssertEqual(localStore.storedProducts.first(where: { $0.id == 1 })?.title, "Remote Newer")
    }

    func testRefreshProductsPrefersNewerRemoteOverOlderLocal() async {
        let olderLocal = ProductTestFixtures.product(
            id: 1,
            title: "Local",
            updatedAt: Date(timeIntervalSince1970: 1000)
        )
        let newerRemote = ProductTestFixtures.product(
            id: 1,
            title: "Remote",
            updatedAt: Date(timeIntervalSince1970: 2000)
        )
        localStore.storedProducts = [olderLocal]
        cloudService.productsToReturn = [newerRemote]

        let didChange = await repository.refreshProducts()

        XCTAssertTrue(didChange)
        XCTAssertEqual(localStore.storedProducts.first?.title, "Remote")
    }

    func testRefreshProductsKeepsNewerLocalWhenRemoteIsOlder() async {
        let newerLocal = ProductTestFixtures.product(
            id: 1,
            title: "Local",
            updatedAt: Date(timeIntervalSince1970: 2000)
        )
        let olderRemote = ProductTestFixtures.product(
            id: 1,
            title: "Remote",
            updatedAt: Date(timeIntervalSince1970: 1000)
        )
        localStore.storedProducts = [newerLocal]
        cloudService.productsToReturn = [olderRemote]

        let didChange = await repository.refreshProducts()

        XCTAssertFalse(didChange)
        XCTAssertEqual(localStore.storedProducts.first?.title, "Local")
        XCTAssertEqual(localStore.saveCallCount, 0)
    }
}
