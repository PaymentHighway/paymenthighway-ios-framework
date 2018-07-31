//
//  PHCardType.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 26/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

public enum CardBrand {
    case unknown
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
    static func matcherPredicateForType(_ cardBrand: CardBrand) -> NSPredicate {
        var regexp: String?
        switch cardBrand {
        case .unknown:
            break
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
}

extension CardBrand: CustomStringConvertible {
    /// Printable
    public var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .visa: return "Visa"
        case .masterCard: return "MasterCard"
        case .americanExpress: return "AmericanExpress"
        case .discover: return "Discover"
        case .jcb: return "JCB"
        case .dinersClub: return "DinersClub"
        }
    }
}
