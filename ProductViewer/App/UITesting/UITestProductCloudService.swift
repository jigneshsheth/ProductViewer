//
//  UITestProductCloudService.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//

import Foundation

final class UITestProductCloudService: ProductCloudService {
    func fetchProducts() async throws -> [Product] {
        ProductUITestFixtures.products
    }
}
