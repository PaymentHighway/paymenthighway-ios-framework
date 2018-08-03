//
//  ExpirationDate.swift
//  PaymentHighway
//
//  Created by Stefano Pironato on 28/06/2018.
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

public struct ExpirationDate {
    let month: String
    let year: String
    
    init(month: String, year: String) {
        self.month = month
        self.year = year
    }
    
    init?(expirationDate: String) {
        guard let (month, year) = ExpirationDate.expirationDateComponents(from: expirationDate) else { return nil }
        self.month = month
        self.year = year
    }
}

extension ExpirationDate {
    
    fileprivate static func expirationDateComponents(from expirationDate: String) -> (month: String, year: String)? {
        guard expirationDate.count == 5 else { return nil }
        let components =  expirationDate.components(separatedBy: "/")
        guard components.count == 2 else { return nil }
        let month = components[0]
        let year = "20" + components[1]
        return (month, year)
    }
    
    static func isValid(expirationDate: String) -> Bool {
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
    
    static func format(expirationDate: String, deleting: Bool = false) -> String {
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
