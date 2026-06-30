//
//  Constants.swift
//  ProductViewer
//
//  Created by Jigs Sheth on 1/27/22.
//

import Foundation

// String is a concrete type, so it's extension can have static let properties.
extension String {

    //  MARK: Product List screen
    static let emptyString = ""
    static let loadingProduct = "Loading Product..."
    static let deals = "Deals"

    //	MARK: Button Title
    static let retryTitle = "Retry!"
    static let okTitle = "ok"
    static let cancelTitle = "cancel"

    //  MARK:Product cell
    static let ship = "ship"
    static let or = "or"

    //  MARK: Product Detail view
    static let addToCart = "add to cart"
    static let addToList = "add to list"
}

enum UserMessages {
    static let loadFailedNoCache = "Unable to load products right now. Check your connection and try again."
    static let refreshFailedWithCache = "Unable to refresh products right now. Showing cached products."
    static let cacheReloadFailed = "Failed to reload products from cache."
    static let cacheLoadFailed = "Failed to load products from cache."
}
