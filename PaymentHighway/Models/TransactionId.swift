//
//  TransactionId.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Struct to hold transaction id
///
public struct TransactionId: IdBase, Decodable {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}
