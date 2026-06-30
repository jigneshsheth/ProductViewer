	//
	//  ProductInfoCellView.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/26/22.
	//

import SwiftUI

	/// Product info screen
struct ProductInfoCellView: View {
	
	@State var product:Product
	
	var body: some View {
		VStack(alignment: .leading){
			Spacer()
			Text(product.title)
				.fontWeight(.light)
				.font(.body)
				.lineLimit(2)
				.foregroundColor(.primary)
				.padding([.trailing,.leading],5)
                .accessibilityIdentifier(AccessibilityID.productTitle(id: product.id))
			Spacer()
			Divider()
			HStack{
				Text(product.regularPrice.displayString)
					.fontWeight(.regular)
					.font(.system(size: 25))
				
				Spacer()
				
				Text(String.ship)
					.font(.callout)
					.fontWeight(.medium)
				
				Text(String.or)
					.fontWeight(.bold)
					.font(.callout)
					.foregroundColor(.gray.opacity(0.4))
				
				Text(product.aisle)
					.fontWeight(.bold)
					.font(.system(size: 13.0))
					.textCase(.uppercase)
					.foregroundColor(.red)
					.padding(10.0)
					.overlay(
						Circle()
							.stroke(Color.gray.opacity(0.4),lineWidth: 1)
					)
			}
			.padding(10)
		}
	}
}

#Preview(traits: .sizeThatFitsLayout) {
    ProductInfoCellView(product:Product.dummyProducts.first!)
        .frame( height:120)
}

