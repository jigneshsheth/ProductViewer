//
//  ProductRepository.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//

import Foundation

protocol ProductRepository {
    func loadProducts() async throws -> [Product]
    func refreshProducts() async -> RefreshOutcome
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
            AppLogger.repository.error("Cache load failed: \(error.localizedDescription, privacy: .public)")
            throw ProductLocalStoreError.readError
        }
    }

    func refreshProducts() async -> RefreshOutcome {
        let localProducts: [Product]
        do {
            localProducts = try localStore.loadProducts()
        } catch {
            AppLogger.repository.error("Refresh local read failed: \(error.localizedDescription, privacy: .public)")
            return .failed(.localStoreReadFailed)
        }

        let remoteProducts: [Product]
        do {
            remoteProducts = try await remoteService.fetchProducts()
        } catch {
            AppLogger.repository.error("Refresh remote fetch failed: \(error.localizedDescription, privacy: .public)")
            return .failed(.remoteFetchFailed)
        }

        let merged = merge(localProducts: localProducts, remoteProducts: remoteProducts)
        let current = deduplicated(localProducts)
        guard merged != current else {
            AppLogger.repository.debug("Refresh completed with no cache changes")
            return .unchanged
        }

        do {
            try localStore.saveProducts(merged)
            AppLogger.repository.info("Refresh updated cache with remote changes")
            return .updated
        } catch {
            AppLogger.repository.error("Refresh cache write failed: \(error.localizedDescription, privacy: .public)")
            return .failed(.localStoreWriteFailed)
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
