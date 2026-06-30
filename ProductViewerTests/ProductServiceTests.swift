	//
	//  ProductViewerTests.swift
	//  ProductViewerTests
	//
	//  Created by Jigs Sheth on 1/27/22.
	//

import XCTest
@testable import ProductViewer

class ProductServiceTests: XCTestCase {
	
	private var productService:ProductCloudService!
	override func setUpWithError() throws {
		productService = ProductCloudServiceImpl()
	}
	
	override func tearDownWithError() throws {
		productService = nil
	}
	
	func testFetchProduct() async throws {
		let products = try await self.productService.fetchProducts()
		XCTAssertEqual(products.count, 25)
		XCTAssertEqual(!products.isEmpty, true)
	}
	
}
