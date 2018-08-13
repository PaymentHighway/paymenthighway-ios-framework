//
//  PaymentConfig.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Payment Highway configuration
///
public struct PaymentConfig {
    
    /// Merchant identifier
    let merchantId: MerchantId

    /// Account identifier
    let accountId: AccountId
    
    public init(merchantId: MerchantId, accountId: AccountId) {
        self.merchantId = merchantId
        self.accountId = accountId
    }
}
