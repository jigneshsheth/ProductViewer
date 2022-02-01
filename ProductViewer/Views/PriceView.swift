	//
	//  PriceView.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/26/22.
	//

import SwiftUI

	/// Price View including Marked down regular price and sale price.
struct PriceView: View {
	
	@State var product:Product
	
	var body: some View {
		HStack {
			Text(product.salePrice?.displayString ?? product.regularPrice.displayString)
				.fontWeight(.bold)
				.font(.system(.largeTitle, design: .rounded))
				.foregroundColor(product.onSale ? Color.accentColor : Color.lightBlack)
			
			Text(product.regularPrice.displayString )
				.strikethrough()
				.fontWeight(.light)
				.font(.system(.title3, design: .rounded))
				.foregroundColor(Color.lightBlack)
				.opacity(product.onSale ? 1 : 0)
			
			Spacer()
		}.padding(.leading)
	}
}

struct PriceView_Previews: PreviewProvider {
	static var previews: some View {
		PriceView(product: Product.dummyProducts.first!)
			.previewLayout(.sizeThatFits)
	}
}
