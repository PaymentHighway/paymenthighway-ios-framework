//
//  CardData.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Struct to hold card info
///
public struct CardData {
    let pan: String
    let cvc: String
    let expiryDate: ExpiryDate
    
    /// init
    ///
    /// - parameter pan: The card number
    /// - parameter cvc: The card security code
    /// - parameter expiryDate: The card expiration date
    init(pan: String, cvc: String, expiryDate: ExpiryDate) {
        self.pan = pan.decimalDigits
        self.cvc = cvc
        self.expiryDate = expiryDate
    }
}

public extension CardData {
    
    /// Validate a given credit card number using the Luhn algorithm
    ///
    /// - parameter   cardNumber: The card number to validate
    /// - returns: true if the credit card is valid
    ///
    static func isValid(cardNumber: String) -> Bool {
        let onlyDigitsCardNumber = cardNumber.decimalDigits
        
        guard let cardBrand = CardBrand.from(cardNumber: onlyDigitsCardNumber),
              cardBrand.panLength.contains(onlyDigitsCardNumber.count) else { return false }

        var sum = 0
        let reversedCharacters = onlyDigitsCardNumber.reversed().map { String($0) }
        for (idx, element) in reversedCharacters.enumerated() {
            guard let digit = Int(element) else { return false }
            switch ((idx % 2 == 1), digit) {
            case (true, 9): sum += 9
            case (true, 0...8): sum += (digit * 2) % 9
            default: sum += digit
            }
        }
        return sum % 10 == 0
    }
    
    /// Format a given card number to a neat string
    ///
    /// - parameter   cardNumber: The card number to format
    /// - returns: The formatted credit card number properly spaced
    ///
    static func format(cardNumber: String) -> String {
        guard let cardBrand = CardBrand.from(cardNumber: cardNumber) else { return cardNumber }
        let maxLen = cardBrand.panLength.max()!
        let formattedString = cardNumber.decimalDigits.truncate(length: maxLen, trailing: "")
        let matches = formattedString.matchesForRegex(cardBrand.formatRegExp)
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
    
    static func format(securityCode: String, cardBrand: CardBrand?) -> String {
        var onlyDigitsSecurityCode = securityCode.decimalDigits
        if let cardBrand = cardBrand, let maxLength = cardBrand.cvcLength.max(), onlyDigitsSecurityCode.count > maxLength {
            let index = onlyDigitsSecurityCode.index(onlyDigitsSecurityCode.startIndex, offsetBy: maxLength)
            onlyDigitsSecurityCode = String(onlyDigitsSecurityCode[..<index])
        } else {
            switch onlyDigitsSecurityCode.count {
            case 0...4 :
                break
            case 5 :
                onlyDigitsSecurityCode.remove(at: onlyDigitsSecurityCode.index(before: onlyDigitsSecurityCode.endIndex))
            default : onlyDigitsSecurityCode = ""
            }
        }
        return onlyDigitsSecurityCode
    }
}
