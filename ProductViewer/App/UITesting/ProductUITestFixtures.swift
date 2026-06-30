//
//  ProductUITestFixtures.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//

import Foundation

enum ProductUITestFixtures {
    static let products: [Product] = (1...10).map { index in
        Product(
            id: index,
            title: "UI Test Product \(index)",
            aisle: "A\(index)",
            productDescription: "Description for UI Test Product \(index)",
            imageURL: "https://picsum.photos/id/\(index + 10)/300/300",
            regularPrice: Price(
                amountInCents: index * 100,
                currencySymbol: .empty,
                displayString: String(format: "$%d.00", index)
            ),
            salePrice: index.isMultiple(of: 3)
                ? Price(
                    amountInCents: index * 50,
                    currencySymbol: .empty,
                    displayString: String(format: "$%.2f", Double(index) / 2.0)
                )
                : nil,
            updatedAt: Date(timeIntervalSince1970: Double(index))
        )
    }
}
