//
//  ContentView.swift
//  ProductViewer
//
//  Created by Jigs Sheth on 1/27/22.
//

import SwiftUI

/// List of Products screen
struct ProductListView: View {

    @State private var productViewModel: ProductViewModelImpl

    init(viewModel: ProductViewModelImpl) {
        _productViewModel = State(initialValue: viewModel)
    }

    @State private var presentAlert = false
    @State private var alertTitle = String.emptyString
    
    var body: some View {
        NavigationView {
            Group {
                if productViewModel.state.products.isEmpty && !presentAlert {
                    LoadingView(text: String.loadingProduct)
                } else {
                    List(productViewModel.state.products) { product in
                        ProductCellViewWithNavigation(product: product)
                    }
                    .accessibilityIdentifier(AccessibilityID.productList)
                    .listStyle(.plain)
                    .navigationTitle(String.deals)
                    .navigationBarTitleDisplayMode(.inline)
                    .refreshable {
                        await self.refreshProductData()
                    }
                }
            }.task {
                await self.loadProductData()
            }
            .alert(alertTitle, isPresented: $presentAlert) {
                Button(
                    String.retryTitle,
                    role: .none,
                    action: {
                        Task {
                            await self.loadProductData()
                        }
                    }
                )
            } message: {
                Text(alertTitle)
            }
        }
        
    }
    
    /// Loading Product data
    private func loadProductData() async {
        await self.productViewModel.loadProducts()
        if let errorMessage = productViewModel.state.errorMessage {
            alertTitle = errorMessage
            presentAlert = true
        }
    }
    
    private func refreshProductData() async {
        await self.productViewModel.refreshProducts()
        if let errorMessage = productViewModel.state.errorMessage {
            alertTitle = errorMessage
            presentAlert = true
        }
    }
    
}

#Preview {
    ProductListView(viewModel: AppDependencies.makeProductViewModel())
}
