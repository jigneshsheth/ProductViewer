//
//  AppDependencies.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//

import Foundation

enum AppDependencies {
    private static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITesting")
            || ProcessInfo.processInfo.environment["UI_TESTING"] == "1"
    }

    static func makeProductRepository(
        remoteService: ProductCloudService? = nil,
        localStore: ProductLocalStore? = nil
    ) -> ProductRepository {
        if isUITesting {
            return ProductRepositoryImpl(
                remoteService: remoteService ?? UITestProductCloudService(),
                localStore: localStore ?? UITestProductLocalStore()
            )
        }

        return ProductRepositoryImpl(
            remoteService: remoteService ?? ProductCloudServiceImpl(),
            localStore: localStore ?? ProductJSONLocalStore()
        )
    }

    @MainActor
    static func makeProductViewModel(repository: ProductRepository? = nil) -> ProductViewModelImpl {
        ProductViewModelImpl(productRepository: repository ?? makeProductRepository())
    }
}
