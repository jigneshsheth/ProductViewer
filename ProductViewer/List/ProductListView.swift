	//
	//  ContentView.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/27/22.
	//

import SwiftUI

	/// List of Products screen
struct ProductListView: View {
	@StateObject
	private var productViewModel = ProductViewModelImpl(productService: ProductServiceImpl())
	
	@State private var presentAlert = false
	@State private var alertTitle = String.emptyString
	
	var body: some View {
		NavigationView{
			Group {
				if productViewModel.productList.isEmpty && !presentAlert{
					LoadingView(text: String.loadingProduct)
				}else{
					List(productViewModel.productList){ product in
						ProductCellViewWithNavigation(product: product)
					}
					.listStyle(.plain)
					.navigationTitle(String.deals)
					.navigationBarTitleDisplayMode(.inline)
					.refreshable {
						await self.loadProductData()
					}
				}
			}.task {
				await self.loadProductData()
			}
			.alert(alertTitle, isPresented: $presentAlert){
				Button(String.retryTitle, role: .none, action: {
					Task{
						await self.loadProductData()
					}
				})
			}message: {
				Text(alertTitle)
			}
		}
		
	}
	
		/// Loading Product data
	private func loadProductData() async {
		do {
			try await self.productViewModel.loadProducts()
		}
		catch {
			alertTitle = error.localizedDescription
			presentAlert = true
		}
	}
	
	
}

struct ProductListView_Previews: PreviewProvider {
	static var previews: some View {
		ProductListView()
	}
}
