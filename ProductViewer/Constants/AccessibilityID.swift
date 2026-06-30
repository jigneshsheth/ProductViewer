//
//  AccessibilityID.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//

import Foundation

enum AccessibilityID {
    static let productList = "productList"
    static let productDetail = "productDetail"
    static let productDetailDescription = "productDetailDescription"
    static let productDetailPrice = "productDetailPrice"

    static func productCell(id: Int) -> String {
        "productCell_\(id)"
    }

    static func productTitle(id: Int) -> String {
        "productTitle_\(id)"
    }
}
