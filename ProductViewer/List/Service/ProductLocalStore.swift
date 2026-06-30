//
//  ProductJSONLocalStore.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//

import Foundation

protocol ProductLocalStore {
    func loadProducts() throws -> [Product]
    func saveProducts(_ products: [Product]) throws
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
            AppLogger.localStore.error("Product cache read error: \(error.localizedDescription, privacy: .public)")
            throw ProductLocalStoreError.readError
        }
    }

    func saveProducts(_ products: [Product]) throws {
        do {
            let data = try encoder.encode(products)
            try data.write(to: cacheURL, options: [.atomic])
        } catch {
            AppLogger.localStore.error("Product cache write error: \(error.localizedDescription, privacy: .public)")
            throw ProductLocalStoreError.writeError
        }
    }
}
