//
//  ProductImageView.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//
import SwiftUI


struct ProductImageView: View {
    let imageURL:String
    var body: some View {
        AsyncImage(url: URL(string:imageURL)){image in
            image
                .resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width:350,height: 350)
        .background(Color.random)
        .cornerRadius(10.0)
        .padding()
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ProductImageView(imageURL: Product.dummyProducts.first!.imageURL)
}
