//
//  ProductTestFixtures.swift
//  ProductViewerTests
//
//  Created by Jigs on 6/29/26.
//

import Foundation
@testable import ProductViewer

enum ProductTestFixtures {
    static let samplePrice = Price(
        amountInCents: 1000,
        currencySymbol: .empty,
        displayString: "$10.00"
    )

    static func product(
        id: Int,
        title: String = "Product",
        aisle: String = "A1",
        updatedAt: Date = .distantPast
    ) -> Product {
        Product(
            id: id,
            title: title,
            aisle: aisle,
            productDescription: "Description for \(title)",
            imageURL: "https://example.com/\(id).jpg",
            regularPrice: samplePrice,
            salePrice: nil,
            updatedAt: updatedAt
        )
    }
}
