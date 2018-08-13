//
//  String+Extension.swift
//  PaymentHighway
//
//  Copyright © 2018 Payment Highway Oy. All rights reserved.
//

import Foundation

extension String {
    
    /// Return only decimal digits
    var decimalDigits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    /// Get a given substring of a string
    /// - parameter r: The range of the substring wanted
    /// - returns: The found substring
    subscript (range: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: range.upperBound - range.lowerBound)
            
            return String(self[(startIndex ..< endIndex)])
        }
    }

    /// Returns matches for given regexp
    /// - parameter regex: The pattern to evaluate
    /// - returns: Found matches as an array
    func matchesForRegex(_ regex: String) -> [String] {
        
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results = regex.matches(in: nsString as String,
                                    options: [],
                                    range: NSRange(location: 0, length: nsString.length))
        
        var strings = [String]()
        
        for result in results {
            for index in 1 ..< result.numberOfRanges {
                let range = result.range(at: index)
                if range.location != NSNotFound {
                    strings.append(nsString.substring(with: range))
                }
            }
        }
        
        return strings
    }
    
    /// Truncates the string to length number of characters and
    /// appends optional trailing string if longer
    /// Source: https://gist.github.com/budidino/8585eecd55fd4284afaaef762450f98e
    func truncate(length: Int, trailing: String? = nil) -> String {
        return (self.count > length) ? self.prefix(length) + (trailing ?? "") : self
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
}
