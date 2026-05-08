//
//  ProductService.swift
//  ProductViewer
//
//  Created by Jigs Sheth on 1/26/22.
//

import Foundation

protocol ProductService {
    func fetchProducts() async throws -> [Product]
}

protocol ProductLocalStore {
    func loadProducts() throws -> [Product]
    func saveProducts(_ products: [Product]) throws
}

protocol ProductRepository {
    func loadCachedProducts() async -> [Product]
    func refreshProductsFromRemote() async -> Bool
    func getProducts() async -> [Product]
}

enum ProductServiceError: Error {
    case invalidUrl
    case invalidUrlRequest
    case dataParsingError
    case requestError
    case internalServerError
    case other
}

// Localized error for Product Service
extension ProductServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return NSLocalizedString(
                "Invalid URL",
                comment: "Url is not valid."
            )
        case .invalidUrlRequest:
            return NSLocalizedString(
                "Invalid URL request!",
                comment: "Invalid URL request!."
            )
        case .dataParsingError:
            return NSLocalizedString(
                "Data Parsing error!",
                comment: "Data parsing error!."
            )
        case .requestError:
            return NSLocalizedString(
                "Request error!",
                comment: "Request error!."
            )
        case .internalServerError:
            return NSLocalizedString(
                "Internal Server error!",
                comment: "Server Internal error!."
            )

        case .other:
            return NSLocalizedString("Unknown error", comment: "Unknown Error.")
        }
    }
}

final class ProductServiceImpl: ProductService {

    /// Fetch Product
    /// - Returns: list of products in array
    func fetchProducts() async throws -> [Product] {
        guard let request = try buildURLRequest(from: APIConstants.dealsApiUrl)
        else {
            throw ProductServiceError.invalidUrlRequest
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let res = (response as? HTTPURLResponse) else {
            throw ProductServiceError.other
        }

        switch res.statusCode {
        case 400..<500:
            throw ProductServiceError.requestError
        case 500..<600:
            throw ProductServiceError.internalServerError
        default:
            print("Successful Request")
        }

        do {
            let products = try JSONDecoder().decode(Products.self, from: data)
            return products.products
        } catch {
            throw error
        }
    }

    /// Build Request URL
    /// - Parameter urlString: url String
    /// - Returns: Optional URL request
    private func buildURLRequest(from urlString: String) throws -> URLRequest? {
        guard let url = URL(string: urlString) else {
            throw ProductServiceError.invalidUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // set any custom header values for request
        return request
    }

}

enum ProductLocalStoreError: Error {
    case readError
    case writeError
}

final class ProductJSONLocalStore: ProductLocalStore {
    private let cacheURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileName: String = "product_cache.json") {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        cacheURL = directory.appendingPathComponent(fileName, isDirectory: false)
    }

    func loadProducts() throws -> [Product] {
        guard FileManager.default.fileExists(atPath: cacheURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: cacheURL)
            return try decoder.decode([Product].self, from: data)
        } catch {
            print("Product cache read error: \(error.localizedDescription)")
            throw ProductLocalStoreError.readError
        }
    }

    func saveProducts(_ products: [Product]) throws {
        do {
            let data = try encoder.encode(products)
            try data.write(to: cacheURL, options: [.atomic])
        } catch {
            print("Product cache write error: \(error.localizedDescription)")
            throw ProductLocalStoreError.writeError
        }
    }
}

final class ProductRepositoryImpl: ProductRepository {
    private let remoteService: ProductService
    private let localStore: ProductLocalStore

    init(remoteService: ProductService, localStore: ProductLocalStore) {
        self.remoteService = remoteService
        self.localStore = localStore
    }

    func loadCachedProducts() async -> [Product] {
        do {
            let cached = try localStore.loadProducts()
            return deduplicated(cached)
        } catch {
            print("Repository cache load failed: \(error.localizedDescription)")
            return []
        }
    }

    func refreshProductsFromRemote() async -> Bool {
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

    func getProducts() async -> [Product] {
        await loadCachedProducts()
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

            if remote.isNewer(than: local) || remote != local {
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
            if product.isNewer(than: existing) || product != existing {
                byId[product.id] = product
            }
        }
        return Array(byId.values)
    }
}
