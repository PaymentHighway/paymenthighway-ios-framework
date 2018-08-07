//
//  AccountId.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 04/07/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Struct to hold account id
///
public struct AccountId: IdBase {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}
