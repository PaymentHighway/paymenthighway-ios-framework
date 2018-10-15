//
//  PurchaseId.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Struct to hold purchase id
///
public struct PurchaseId: IdBase {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}
