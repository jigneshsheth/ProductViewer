//
//  Product.swift
//  ProductViewer
//
//  Created by Jigs Sheth on 1/25/22.
//

import Foundation

// MARK: - Product
struct Product: Codable,Identifiable {
    let id: Int
    let title, aisle, productDescription: String
    let imageURL: String
    let regularPrice: Price
    let salePrice: Price?
    
    enum CodingKeys: String, CodingKey {
        case id, title, aisle
        case productDescription = "description"
        case imageURL = "image_url"
        case regularPrice = "regular_price"
        case salePrice = "sale_price"
    }
}

extension Product {
    var onSale:Bool {
        guard let _ = self.salePrice else {
            return false
        }
        return true
    }
}



extension Product {
	
		/// Dummy data for validation
	static let dummyProducts:[Product] = [
		Product(id: 1, title: "This is Product Title.....", aisle: "B1", productDescription: "This is Product Description", imageURL: "https://picsum.photos/id/23/300/300", regularPrice:Price(amountInCents: 5000, currencySymbol: .empty, displayString: "$50.00"), salePrice: Price(amountInCents: 1500, currencySymbol: .empty, displayString: "$15.00") ),
		Product(id: 1, title: "This is Product Title.....", aisle: "B2", productDescription: "This is Product Description", imageURL: "https://picsum.photos/id/23/300/300", regularPrice:Price(amountInCents: 5000, currencySymbol: .empty, displayString: "$50.00"), salePrice: Price(amountInCents: 1500, currencySymbol: .empty, displayString: "$15.00") ),
		Product(id: 1, title: "This is Product Title.....", aisle: "B3", productDescription: "This is Product Description", imageURL: "https://picsum.photos/id/23/300/300", regularPrice:Price(amountInCents: 5000, currencySymbol: .empty, displayString: "$50.00"), salePrice: Price(amountInCents: 1500, currencySymbol: .empty, displayString: "$15.00") ),
		Product(id: 1, title: "This is Product Title.....", aisle: "B4", productDescription: "This is Product Description", imageURL: "https://picsum.photos/id/23/300/300", regularPrice:Price(amountInCents: 5000, currencySymbol: .empty, displayString: "$50.00"), salePrice: Price(amountInCents: 1500, currencySymbol: .empty, displayString: "$15.00") ),
		Product(id: 1, title: "This is Product Title.....", aisle: "B5", productDescription: "This is Product Description", imageURL: "https://picsum.photos/id/23/300/300", regularPrice:Price(amountInCents: 5000, currencySymbol: .empty, displayString: "$50.00"), salePrice: Price(amountInCents: 1500, currencySymbol: .empty, displayString: "$15.00") )
	]
}
