	//
	//  ProductDetailView.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/26/22.
	//

import SwiftUI


	/// Product Detail View
struct ProductDetailView: View {
	let product:Product
	@State private var presentAlert = false
	@State private var alertTitle = String.emptyString
	
	var body: some View {
		VStack(spacing: 10){
			ScrollView{
				
				ProductImageView(imageURL: product.imageURL)
				
				PriceView(product: product)
				
				MultilineTextView(multiLineText: product.productDescription)
			}
			
			ButtonView(title: String.addToCart, backgroundColor: Color.accentColor, foregroundColor: .white){
				alertTitle = String.addToCart.uppercased()
				presentAlert = true
			}
	
			ButtonView(title: String.addToList, backgroundColor: Color.gray.opacity(0.2), foregroundColor: .black){
				alertTitle = String.addToList.uppercased()
				presentAlert = true
			}
			
		}
		.navigationTitle(product.title)
		.alert(alertTitle, isPresented: $presentAlert){
			Button(String.okTitle, role: .none, action: {})
			Button(String.cancelTitle,role:.cancel,action:{})
		}message: {
			Text(product.title)
		}
	}
}

struct ProductDetailView_Previews: PreviewProvider {
	static var previews: some View {
		ProductDetailView(product: Product.dummyProducts.last! )
	}
}




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
