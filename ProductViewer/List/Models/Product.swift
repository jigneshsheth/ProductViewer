//
//  Product.swift
//  ProductViewer
//
//  Created by Jigs Sheth on 1/25/22.
//

import Foundation

// MARK: - Product
struct Product: Codable, Identifiable, Equatable {
    let id: Int
    let title, aisle, productDescription: String
    let imageURL: String
    let regularPrice: Price
    let salePrice: Price?
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, aisle
        case productDescription = "description"
        case imageURL = "image_url"
        case regularPrice = "regular_price"
        case salePrice = "sale_price"
        case updatedAt = "updated_at"
    }

    init(
        id: Int,
        title: String,
        aisle: String,
        productDescription: String,
        imageURL: String,
        regularPrice: Price,
        salePrice: Price?,
        updatedAt: Date = .distantPast
    ) {
        self.id = id
        self.title = title
        self.aisle = aisle
        self.productDescription = productDescription
        self.imageURL = imageURL
        self.regularPrice = regularPrice
        self.salePrice = salePrice
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        aisle = try container.decode(String.self, forKey: .aisle)
        productDescription = try container.decode(String.self, forKey: .productDescription)
        imageURL = try container.decode(String.self, forKey: .imageURL)
        regularPrice = try container.decode(Price.self, forKey: .regularPrice)
        salePrice = try container.decodeIfPresent(Price.self, forKey: .salePrice)
        updatedAt = try Product.decodeUpdatedAt(from: container)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(aisle, forKey: .aisle)
        try container.encode(productDescription, forKey: .productDescription)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(regularPrice, forKey: .regularPrice)
        try container.encodeIfPresent(salePrice, forKey: .salePrice)
        try container.encode(Product.iso8601Formatter.string(from: updatedAt), forKey: .updatedAt)
    }

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let fallbackIso8601Formatter = ISO8601DateFormatter()

    private static func decodeUpdatedAt(from container: KeyedDecodingContainer<CodingKeys>) throws -> Date {
        if let dateString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            if let parsed = iso8601Formatter.date(from: dateString)
                ?? fallbackIso8601Formatter.date(from: dateString) {
                return parsed
            }
            print("Product decode warning: invalid updated_at format '\(dateString)'; defaulting to distantPast")
            return .distantPast
        }

        if let timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .updatedAt) {
            return Date(timeIntervalSince1970: timestamp)
        }

        return .distantPast
    }
}

extension Product {
    var onSale: Bool {
        guard self.salePrice != nil else {
            return false
        }
        return true
    }

    var sortableComparisonKey: Date {
        updatedAt
    }

    func isNewer(than other: Product) -> Bool {
        sortableComparisonKey > other.sortableComparisonKey
    }
}

extension Product {

    /// Dummy data for validation
    static let dummyProducts: [Product] = [
        Product(
            id: 1,
            title: "This is Product Title.....",
            aisle: "B1",
            productDescription: "This is Product Description",
            imageURL: "https://picsum.photos/id/23/300/300",
            regularPrice: Price(
                amountInCents: 5000,
                currencySymbol: .empty,
                displayString: "$50.00"
            ),
            salePrice: Price(
                amountInCents: 1500,
                currencySymbol: .empty,
                displayString: "$15.00"
            )
        ),
        Product(
            id: 1,
            title: "This is Product Title.....",
            aisle: "B2",
            productDescription: "This is Product Description",
            imageURL: "https://picsum.photos/id/23/300/300",
            regularPrice: Price(
                amountInCents: 5000,
                currencySymbol: .empty,
                displayString: "$50.00"
            ),
            salePrice: Price(
                amountInCents: 1500,
                currencySymbol: .empty,
                displayString: "$15.00"
            )
        ),
        Product(
            id: 1,
            title: "This is Product Title.....",
            aisle: "B3",
            productDescription: "This is Product Description",
            imageURL: "https://picsum.photos/id/23/300/300",
            regularPrice: Price(
                amountInCents: 5000,
                currencySymbol: .empty,
                displayString: "$50.00"
            ),
            salePrice: Price(
                amountInCents: 1500,
                currencySymbol: .empty,
                displayString: "$15.00"
            )
        ),
        Product(
            id: 1,
            title: "This is Product Title.....",
            aisle: "B4",
            productDescription: "This is Product Description",
            imageURL: "https://picsum.photos/id/23/300/300",
            regularPrice: Price(
                amountInCents: 5000,
                currencySymbol: .empty,
                displayString: "$50.00"
            ),
            salePrice: Price(
                amountInCents: 1500,
                currencySymbol: .empty,
                displayString: "$15.00"
            )
        ),
        Product(
            id: 1,
            title: "This is Product Title.....",
            aisle: "B5",
            productDescription: "This is Product Description",
            imageURL: "https://picsum.photos/id/23/300/300",
            regularPrice: Price(
                amountInCents: 5000,
                currencySymbol: .empty,
                displayString: "$50.00"
            ),
            salePrice: Price(
                amountInCents: 1500,
                currencySymbol: .empty,
                displayString: "$15.00"
            )
        ),
    ]
}
