//
//  Price.swift
//  ProductViewer
//
//  Created by Jigs Sheth on 1/25/22.
//

import Foundation
// MARK: - Price
struct Price: Codable {
    let amountInCents: Int
    let currencySymbol: CurrencySymbol
    let displayString: String

    enum CodingKeys: String, CodingKey {
        case amountInCents = "amount_in_cents"
        case currencySymbol = "currency_symbol"
        case displayString = "display_string"
    }
}

