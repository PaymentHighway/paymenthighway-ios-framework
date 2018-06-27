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
}

extension ExpirationDate {
    
    static func isValid(expirationDate: String) -> Bool {
        
        if expirationDate.count == 5 {
            let month = expirationDate.components(separatedBy: "/")[0]
            let year = "20" + expirationDate.components(separatedBy: "/")[1]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMyyyy"
            
            if let givenDate = dateFormatter.date(from: month + year),
                let currentDate = dateFormatter.date(from: dateFormatter.string(from: Date())),
                givenDate.compare(currentDate) != ComparisonResult.orderedAscending {
                return true
            }
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
