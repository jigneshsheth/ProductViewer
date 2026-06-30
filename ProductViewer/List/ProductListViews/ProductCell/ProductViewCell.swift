//
//  ProductViewCell.swift
//  ProductViewer
//
//  Created by Jigs Sheth on 1/26/22.
//

import SwiftUI

/// Product  cell with Image
struct ProductViewCell: View {
    
    @State var product:Product
    
    var body: some View {
        HStack(spacing:5){
            AsyncImage(url: URL(string:product.imageURL)){image in
                image
                    .resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 90, height: 110)
            .background(Color.random)
            .cornerRadius(5.0)
            .padding(5.0)
            
            ProductInfoCellView(product: product)
            
        }
        .foregroundColor(.primary)
        .listRowSeparator(.hidden)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ProductViewCell(product: Product.dummyProducts.first!)
        .frame(height:120)
}

