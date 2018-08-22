//
//  ExpirationDate.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Struct to hold card expiration date
///
public struct ExpirationDate {
    let month: String
    let year: String
    
    /// Init with month and year
    ///
    /// month will formatted as MM
    /// year will formatted as YYYY
    ///
    /// - parameter month: month as string: 1 or 2 chars, accepted "1" - "12"
    /// - parameter year: year as string: 1 to 4 chars. For years <= 999 2000 is added
    /// - returns: nil in case of invalid date
    ///
    public init?(month: String, year: String) {
        let expirationDate = "\(month)/\(year)"
        guard let checked = ExpirationDate.expirationDateComponents(from: expirationDate) else { return nil }
        self.month = checked.month
        self.year = checked.year
    }
    
    /// Init with raw expiration date string
    ///
    /// month will formatted as MM
    /// year will formatted as YYYY
    ///
    /// - parameter expirationDate: raw expiration date, format "M[M]/Y[YYY]"
    /// - returns: nil in case of invalid date
    ///
    public init?(expirationDate: String) {
        guard let (month, year) = ExpirationDate.expirationDateComponents(from: expirationDate) else { return nil }
        self.month = month
        self.year = year
    }
}

extension ExpirationDate {
    
    fileprivate static func expirationDateComponents(from expirationDate: String, separator: String = "/") -> (month: String, year: String)? {
        let components =  expirationDate.components(separatedBy: separator)
        guard components.count == 2 else { return nil }
        guard let monthNumber = Int(components[0]), (1...12).contains(monthNumber) else { return nil }
        let month = String(format: "%02d", monthNumber)
        guard let yearNumber = Int(components[1]) else { return nil }
        let year = String(format: "%04d", yearNumber <= 999 ? yearNumber+2000 : yearNumber)
        return (month, year)
    }
    
    /// Check if expiration date is valid
    ///
    /// - parameter expirationDate: accepted format "M[M]/Y[YYY]"
    /// - returns: true if expiration date is valid
    ///
    public static func isValid(expirationDate: String) -> Bool {
        guard let (month, year) = expirationDateComponents(from: expirationDate) else { return false }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMyyyy"
        
        if let givenDate = dateFormatter.date(from: month + year),
            let currentDate = dateFormatter.date(from: dateFormatter.string(from: Date())),
            givenDate.compare(currentDate) != ComparisonResult.orderedAscending {
            return true
        }
        
        return false
    }
    
    /// Format the expiration date
    ///
    /// ````
    /// example: previous input  user input  formatted
    ///                             2           02/
    ///             0               8           08/
    ///             01/             2           01/2
    ///             08/             <del>       0
    ///             08/2            <del>       08/
    /// ````
    ///
    /// - parameter expirationDate: input expiration date
    /// - parameter deleting: need to know if there has been a delete since format change based on it(check example above)
    /// - returns: expiration date formatted
    ///
    public static func format(expirationDate: String, deleting: Bool = false) -> String {
        var onlyDigitsExpirationDate = expirationDate.decimalDigits
        let length = onlyDigitsExpirationDate.count
        
        var text = ""
        
        switch length {
        case 1:
            if 2...9 ~= Int(onlyDigitsExpirationDate)! {
                text = "0\(onlyDigitsExpirationDate)/"
            } else {
                text = onlyDigitsExpirationDate
            }
        case 2:
            if (deleting && expirationDate.count == 2) ||
                (Int(onlyDigitsExpirationDate)! < 1 || Int(onlyDigitsExpirationDate)! > 12) {
                onlyDigitsExpirationDate.remove(at: onlyDigitsExpirationDate.index(before: onlyDigitsExpirationDate.endIndex))
                text = onlyDigitsExpirationDate
            } else {
                text = "\(onlyDigitsExpirationDate)/"
            }
        case 3:
            onlyDigitsExpirationDate.insert("/", at: onlyDigitsExpirationDate.index(onlyDigitsExpirationDate.startIndex, offsetBy: 2))
            text = onlyDigitsExpirationDate
        case 4:
            onlyDigitsExpirationDate.insert("/", at: onlyDigitsExpirationDate.index(onlyDigitsExpirationDate.startIndex, offsetBy: 2))
            text = onlyDigitsExpirationDate
        case 5:
            onlyDigitsExpirationDate.remove(at: onlyDigitsExpirationDate.index(before: onlyDigitsExpirationDate.endIndex))
            onlyDigitsExpirationDate.insert("/", at: onlyDigitsExpirationDate.index(onlyDigitsExpirationDate.startIndex, offsetBy: 2))
            text = onlyDigitsExpirationDate
        default:
            text = ""
        }
        
        return text
    }
}
