//
//  RefreshOutcome.swift
//  ProductViewer
//
//  Created by Jigs on 6/29/26.
//

import Foundation

enum RefreshFailure: Equatable {
    case localStoreReadFailed
    case remoteFetchFailed
    case localStoreWriteFailed
}

enum RefreshOutcome: Equatable {
    case updated
    case unchanged
    case failed(RefreshFailure)
}

extension RefreshFailure {
    func userMessage(hasCachedProducts: Bool) -> String {
        switch self {
        case .localStoreReadFailed, .localStoreWriteFailed:
            return hasCachedProducts
                ? UserMessages.refreshFailedWithCache
                : UserMessages.loadFailedNoCache
        case .remoteFetchFailed:
            return hasCachedProducts
                ? UserMessages.refreshFailedWithCache
                : UserMessages.loadFailedNoCache
        }
    }
}
