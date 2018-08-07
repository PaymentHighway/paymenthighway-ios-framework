//
//  CardData.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 28/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Struct to hold card info
///
public struct CardData {
    let pan: String
    let cvc: String
    let expirationDate: ExpirationDate
    
    /// init
    ///
    /// - parameter pan: The card number
    /// - parameter cvc: The card security code
    /// - parameter expirationDate: The card expiration date
    init(pan: String, cvc: String, expirationDate: ExpirationDate) {
        self.pan = pan.decimalDigits
        self.cvc = cvc
        self.expirationDate = expirationDate
    }
}

public extension CardData {
    
    /// Recognize the card brand of a credit card number
    ///
    /// - parameter cardNumber: The card number string
    static func cardBrand(cardNumber: String) -> CardBrand? {
        let cardNumberDigits = cardNumber.decimalDigits
        let valid = isValid(cardNumber: cardNumberDigits)
        guard valid else { return nil }        
        var foundCardBrand: CardBrand? = nil
        for cardBrand in CardBrand.allCases {
            if cardBrand.matcherPredicate.evaluate(with: cardNumberDigits) == true {
                if cardBrand.panLength.contains(cardNumberDigits.count) {
                    foundCardBrand = cardBrand
                    break
                }
            }
        }
        
        return foundCardBrand
    }
    
    /// Validate a given credit card number using the Luhn algorithm
    ///
    /// - parameter   cardNumber: The card number to validate
    /// - returns: true if the credit card is valid
    ///
    static func isValid(cardNumber: String) -> Bool {
        let formattedString = cardNumber.decimalDigits
        guard formattedString.count >= 9 else { return false }
        
        let asciiOffset: UInt8 = 48
        let digits = Array(Array(formattedString.utf8).reversed()).map {$0 - asciiOffset}
        
        let convert: (UInt8) -> (UInt8) = {
            let num = $0 * 2
            return num > 9 ? num - 9 : num
        }
        
        var sum: UInt8 = 0
        for (index, digit) in digits.enumerated() {
            if index & 1 == 1 {
                sum += convert(digit)
            } else {
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
    
    /// Format a given card number to a neat string
    ///
    /// - parameter   cardNumber: The card number to format
    /// - parameter   cardBrand: The card brand
    /// - returns: The formatted credit card number properly spaced
    ///
    static func format(cardNumber: String, cardBrand: CardBrand?) -> String {
        let formattedString = cardNumber.decimalDigits.truncate(length: 19, trailing: "")
        
        // AMEX uses their own weird format
        var regexpString = "(\\d{1,4})"
        if let cardBrand = cardBrand,
           cardBrand == .americanExpress {
            regexpString = "(\\d{1,4})(\\d{1,6})?(\\d{1,5})?"
        }
        
        // Create and check regexp matches
        // let regexp  = try! NSRegularExpression(pattern: regexpString, options: [])
        // var groups  = [String]()
        
        let matches = formattedString.matchesForRegex(regexpString)
        
        // Glue them together
        return matches.joined(separator: " ")
    }
    
    /// Validate a given security code
    /// Need the card brand to understand the lenght of the security code
    ///
    /// - parameter   securityCode: the security code
    /// - returns: true secure code is valid
    ///
    static func isValid(securityCode: String, cardBrand: CardBrand?) -> Bool {
        guard let cardBrand = cardBrand else { return false }
        return  cardBrand.cvcLength.contains(securityCode.decimalDigits.count)
    }
    
    static func format(securityCode: String) -> String {
        var onlyDigitsSecurityCode = securityCode.decimalDigits
        var text = ""
        switch onlyDigitsSecurityCode.count {
        case 0...4 :
            text = onlyDigitsSecurityCode
        case 5 :
            onlyDigitsSecurityCode.remove(at: onlyDigitsSecurityCode.index(before: onlyDigitsSecurityCode.endIndex))
            text = onlyDigitsSecurityCode
        default : text = ""
        }
        return text
    }
}
