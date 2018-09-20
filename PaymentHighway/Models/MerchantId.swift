//
//  MerchantId.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Struct to hold merchant id
///
public struct MerchantId: IdBase {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}
