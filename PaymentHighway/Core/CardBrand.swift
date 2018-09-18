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
    
    /// Mastercard card
    case mastercard
    
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
        return [.visa, .mastercard, .americanExpress, .discover, .jcb, .dinersClub]
    }

    /// Initialize card brand from a credit card number
    ///
    /// - parameter cardNumber: The card number string
    public init?(cardNumber: String) {
        let cardNumberDigits = cardNumber.decimalDigits
        let result = CardBrand.allCases.filter { $0.pattern.firstMatch(in: cardNumberDigits,
                                                                    range: NSRange(location: 0, length: cardNumberDigits.utf8.count)) != nil}
        guard !result.isEmpty else { return nil }
        self = result[0]
    }
}

// swiftlint:disable force_try
extension CardBrand {
    
    /// Returns the pattern to recognise a card brand
    fileprivate var pattern: NSRegularExpression {
        var regexp: String
        switch self {
        case .visa:
            regexp = "^4[0-9]"
        case .mastercard:
            regexp = "^(?:5[1-5]|2[2-7])"
        case .americanExpress:
            regexp = "^3[47]"
        case .discover:
            regexp = "^(?:6[045]|622)"
        case .jcb:
            regexp = "^35"
        case .dinersClub:
            regexp = "^3[0689]"
        }
        return try! NSRegularExpression(pattern: regexp)
    }
    
    /// Returns the correct card number length for validating card brand
    var panLength: [Int] {
        switch self {
        case .visa: return [13, 16]
        case .mastercard: return [16]
        case .americanExpress: return [15]
        case .discover: return [16]
        case .jcb: return [16]
        case .dinersClub: return [14]
        }
    }
    
    /// Returns regular expression string for formatting the card brand
    var formatRegExp: String {
        var regexp: String
        switch self {
        case .americanExpress: regexp = "(\\d{1,4})(\\d{1,6})?(\\d{1,5})?"
        case .dinersClub: regexp = "(\\d{1,4})(\\d{1,6})?(\\d{1,4})?"
        default: regexp = "(\\d{1,4})"
        }
        return regexp
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
        case .mastercard: return "Mastercard"
        case .americanExpress: return "American Express"
        case .discover: return "Discover"
        case .jcb: return "JCB"
        case .dinersClub: return "Diners Club"
        }
    }
}
