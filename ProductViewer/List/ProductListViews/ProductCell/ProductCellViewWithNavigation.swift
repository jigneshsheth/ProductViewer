	//
	//  ProductViewCellwithNavigation.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/26/22.
	//

import SwiftUI

	/// Wrap Product Cell with Navigation
struct ProductCellViewWithNavigation: View {
	
	let product:Product
	
	var body: some View {
		VStack{
			ProductViewCell(product: product)
			NavigationLink(destination:ProductDetailView(product: product) ) {
				EmptyView()
			}
			.opacity(0)
		}
		.listRowSeparator(.hidden)
	}
}

struct ProductViewCellwithNavigation_Previews: PreviewProvider {
	static var previews: some View {
		ProductCellViewWithNavigation(product: Product.dummyProducts.first!)
			.frame( height: 150)
			.previewLayout(.sizeThatFits)
	}
}
