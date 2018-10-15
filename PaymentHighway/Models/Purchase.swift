//
//  Purchase.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Payment Highway purchase
///
public struct Purchase {
    
    /// Purchase identifier
    let purchaseId: PurchaseId
    
    /// Currency codes based on the ISO 4217 standard
    let currency: String
    
    // Amount of the purchase
    let amount: Double
    
    // Purchase description
    let description: String
    
    public init(purchaseId: PurchaseId, currency: String, amount: Double, description: String) {
        self.purchaseId = purchaseId
        self.currency = currency
        self.amount = amount
        self.description = description
    }
    
    var amountWithCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount))!
    }

}
