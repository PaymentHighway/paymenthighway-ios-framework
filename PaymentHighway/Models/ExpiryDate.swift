//
//  ExpiryDate
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

/// Struct to hold card expiry date
///
public struct ExpiryDate {
    let month: String
    let year: String
    
    /// Init with month and year
    ///
    /// month will formatted as MM
    /// year will formatted as YYYY
    ///
    /// - parameter month: 1-2 numeric chars, accepted 1-12
    /// - parameter year: 1-4 numeric chars. For years <= 999 2000 is adde
    /// - returns: nil in case of invalid date
    ///
    public init?(month: String, year: String) {
        let expiryDate = "\(month)/\(year)"
        guard let checked = ExpiryDate.expiryDateComponents(from: expiryDate) else { return nil }
        self.month = checked.month
        self.year = checked.year
    }
    
    /// Init with raw expiration date string
    ///
    /// month will formatted as MM
    /// year will formatted as YYYY
    ///
    /// - parameter expiryDate: raw expiration date, format "M[M]/Y[YYY]"
    /// - returns: nil in case of invalid date
    ///
    public init?(expiryDate: String) {
        guard let (month, year) = ExpiryDate.expiryDateComponents(from: expiryDate) else { return nil }
        self.month = month
        self.year = year
    }
}

extension ExpiryDate {
    
    fileprivate static func expiryDateComponents(from expiryDate: String, separator: String = "/") -> (month: String, year: String)? {
        let components =  expiryDate.components(separatedBy: separator)
        guard components.count == 2 else { return nil }
        guard let monthNumber = Int(components[0]), (1...12).contains(monthNumber) else { return nil }
        let month = String(format: "%02d", monthNumber)
        guard let yearNumber = Int(components[1]) else { return nil }
        let year = String(format: "%04d", yearNumber <= 999 ? yearNumber+2000 : yearNumber)
        return (month, year)
    }
    
    /// Check if expiration date is valid
    ///
    /// - parameter expiryDate: accepted format "M[M]/Y[YYY]"
    /// - returns: true if expiration date is valid
    ///
    public static func isValid(expiryDate: String) -> Bool {
        guard let (month, year) = expiryDateComponents(from: expiryDate) else { return false }
        
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
    /// - parameter expiryDate: input expiration date
    /// - parameter deleting: need to know if there has been a delete since format change based on it(check example above)
    /// - returns: expiry date formatted
    ///
    public static func format(expiryDate: String, deleting: Bool = false) -> String {
        var onlyDigitsExpiryDate = expiryDate.decimalDigits
        switch onlyDigitsExpiryDate.count {
        case 1:
            if 2...9 ~= Int(onlyDigitsExpiryDate)! {
                onlyDigitsExpiryDate = "0\(onlyDigitsExpiryDate)/"
            }
        case 2:
            let digitsAsInt = Int(onlyDigitsExpiryDate)!
            if (deleting && expiryDate.count == 2) || (digitsAsInt < 1 || digitsAsInt > 12) {
                onlyDigitsExpiryDate.remove(at: onlyDigitsExpiryDate.index(before: onlyDigitsExpiryDate.endIndex))
            } else {
                onlyDigitsExpiryDate = "\(onlyDigitsExpiryDate)/"
            }
        case 5:
            onlyDigitsExpiryDate.remove(at: onlyDigitsExpiryDate.index(before: onlyDigitsExpiryDate.endIndex))
            fallthrough
        case 3, 4:
            onlyDigitsExpiryDate.insert("/", at: onlyDigitsExpiryDate.index(onlyDigitsExpiryDate.startIndex, offsetBy: 2))
        default:
            onlyDigitsExpiryDate = ""
        }
        
        return onlyDigitsExpiryDate
    }
}
