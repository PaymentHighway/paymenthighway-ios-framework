//
//  PHCardType.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 26/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

public enum CardBrand {
    case visa
    case masterCard
    case americanExpress
    case discover
    case jcb
    case dinersClub
    
    static var allCases: [CardBrand] {
        return [.visa, .masterCard, .americanExpress, .discover, .jcb, .dinersClub]
    }

}

extension CardBrand {
    /// Returns the correct NSPredicate for validating a card type
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
    
    var cvcLength: [Int] {
        switch self {
        case .americanExpress: return [3, 4]
        default: return [3]
        }
    }
}

extension CardBrand: CustomStringConvertible {
    /// Printable
    public var description: String {
        switch self {
        case .visa: return "Visa"
        case .masterCard: return "MasterCard"
        case .americanExpress: return "AmericanExpress"
        case .discover: return "Discover"
        case .jcb: return "JCB"
        case .dinersClub: return "DinersClub"
        }
    }
}
