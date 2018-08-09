//
//  TextFieldType.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 01/08/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Enumeration of the specialized text fields UI elements for card entry
///
public enum TextFieldType {
    /// Card number text field
    case cardNumber
    
    /// Expiration date text field
    case expirationDate

    /// Security code text field
    case securityCode
}

extension TextFieldType {
    func iconId(cardBrand: CardBrand?) -> String {
        switch self {
        case .cardNumber: return "cardicon"
        case .expirationDate: return "calendaricon"
        case .securityCode: return "lockicon"
        }
    }
}
