//
//  PHCardType.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Card brands to which a payment card can belong.
///
public enum CardBrand {
    
    /// Visa card
    case visa
    
    /// MasterCard card
    case masterCard
    
    /// American Express card
    case americanExpress
    
    /// Discover card
    case discover
    
    /// JCB card
    case jcb
    
    /// Dinners Club card
    case dinersClub
    
    /// return array with all card brands
    public static var allCases: [CardBrand] {
        return [.visa, .masterCard, .americanExpress, .discover, .jcb, .dinersClub]
    }

}

extension CardBrand {
    
    /// Returns the correct predicate for validating a card brand
    var matcherPredicate: NSPredicate {
        var regexp: String?
        switch self {
        case .visa:
            regexp = "^4[0-9]{6,}$"
        case .masterCard:
            regexp = "^5[1-5][0-9]{5,}$"
        case .americanExpress:
            regexp = "^3[47][0-9]{5,}$"
        case .discover:
            regexp = "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .jcb:
            regexp = "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .dinersClub:
            regexp = "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        }
        
        if let regexp = regexp {
            return NSPredicate(format: "SELF MATCHES %@", regexp)
        }
        return NSPredicate(value: false)
    }
    
    /// Returns the correct card number length for validating card brand
    var panLength: [Int] {
        switch self {
        case .visa: return [13, 16]
        case .masterCard: return [16]
        case .americanExpress: return [15]
        case .discover: return [16]
        case .jcb: return [16]
        case .dinersClub: return [14]
        }
    }
    
    /// Returns the correct security code length for validating card brand
    var cvcLength: [Int] {
        switch self {
        case .americanExpress: return [3, 4]
        default: return [3]
        }
    }
}

extension CardBrand: CustomStringConvertible {
    /// Card brand printable
    public var description: String {
        switch self {
        case .visa: return "Visa"
        case .masterCard: return "Mastercard"
        case .americanExpress: return "American Express"
        case .discover: return "Discover"
        case .jcb: return "JCB"
        case .dinersClub: return "Diners Club"
        }
    }
}
