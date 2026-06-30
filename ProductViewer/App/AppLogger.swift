//
//  AppLogger.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//

import Foundation
import os

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.target.ProductViewer"

    static let repository = Logger(subsystem: subsystem, category: "ProductRepository")
    static let localStore = Logger(subsystem: subsystem, category: "ProductLocalStore")
    static let cloudService = Logger(subsystem: subsystem, category: "ProductCloudService")
    static let product = Logger(subsystem: subsystem, category: "Product")
}
