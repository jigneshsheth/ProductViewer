//
//  ProductListState.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//

import Foundation

struct ProductListState: Equatable {
    let products: [Product]
    let errorMessage: String?
}
