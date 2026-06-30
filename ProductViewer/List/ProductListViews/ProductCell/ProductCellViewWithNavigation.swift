//
//  ProductViewCellwithNavigation.swift
//  ProductViewer
//
//  Created by Jigs Sheth on 1/26/22.
//

import SwiftUI

/// Wrap Product Cell with Navigation
struct ProductCellViewWithNavigation: View {
    
    let product: Product
    
    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            ProductViewCell(product: product)
        }
        .buttonStyle(.plain)
        .listRowSeparator(.hidden)
        .accessibilityIdentifier(AccessibilityID.productCell(id: product.id))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ProductCellViewWithNavigation(product: Product.dummyProducts.first!)
        .frame(height: 120)
}
