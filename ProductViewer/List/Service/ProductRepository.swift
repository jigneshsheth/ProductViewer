//
//  ProductRepository.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//

import Foundation

protocol ProductRepository {
    func loadProducts() async throws-> [Product]
    func refreshProducts() async -> Bool
}

final class ProductRepositoryImpl: ProductRepository {
    
    private let remoteService: ProductCloudService
    private let localStore: ProductLocalStore

    init(remoteService: ProductCloudService, localStore: ProductLocalStore) {
        self.remoteService = remoteService
        self.localStore = localStore
    }

    func loadProducts() async throws -> [Product] {
        do {
            let cached = try localStore.loadProducts()
            return deduplicated(cached)
        } catch {
            print("Repository cache load failed: \(error.localizedDescription)")
            throw ProductLocalStoreError.readError
//            return []
        }
    }

    func refreshProducts() async -> Bool {
        do {
            let localProducts = try localStore.loadProducts()
            let remoteProducts = try await remoteService.fetchProducts()
            let merged = merge(localProducts: localProducts, remoteProducts: remoteProducts)
            let current = deduplicated(localProducts)
            if merged != current {
                try localStore.saveProducts(merged)
                print("Repository refresh: cache updated with remote changes")
                return true
            }
            print("Repository refresh: no cache change needed")
            return false
        } catch {
            print("Repository remote refresh failed: \(error.localizedDescription)")
            return false
        }
    }

 
    private func deduplicated(_ products: [Product]) -> [Product] {
        let merged = merge(localProducts: [], remoteProducts: products)
        return merged.sorted(by: { $0.id < $1.id })
    }

    private func merge(localProducts: [Product], remoteProducts: [Product]) -> [Product] {
        var localById = Dictionary(uniqueKeysWithValues: deduplicatedByNewest(products: localProducts).map { ($0.id, $0) })
        let remoteNewestById = Dictionary(uniqueKeysWithValues: deduplicatedByNewest(products: remoteProducts).map { ($0.id, $0) })

        for (id, remote) in remoteNewestById {
            guard let local = localById[id] else {
                localById[id] = remote
                continue
            }

            if remote.isNewer(than: local) {
                localById[id] = remote
            } else if remote.updatedAt == local.updatedAt && remote != local {
                localById[id] = remote
            }
        }

        return localById.values.sorted(by: { $0.id < $1.id })
    }

    private func deduplicatedByNewest(products: [Product]) -> [Product] {
        var byId: [Int: Product] = [:]
        for product in products {
            guard let existing = byId[product.id] else {
                byId[product.id] = product
                continue
            }
            if product.isNewer(than: existing) {
                byId[product.id] = product
            } else if product.updatedAt == existing.updatedAt {
                byId[product.id] = product
            }
        }
        return Array(byId.values)
    }
}
