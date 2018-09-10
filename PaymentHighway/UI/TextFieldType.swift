//
//  TextFieldType.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

/// Enumeration of the specialized text fields UI elements for card entry
///
public enum TextFieldType {
    /// Card number text field
    case cardNumber
    
    /// Expiration date text field
    case expiryDate

    /// Security code text field
    case securityCode
}

extension TextFieldType {
    func iconId(cardBrand: CardBrand?) -> String {
        switch self {
        case .cardNumber: return "cardicon"
        case .expiryDate: return "calendaricon"
        case .securityCode: return "lockicon"
        }
    }
}
