//
//  SPH.swift
//  Clutch
//
//  Created by Nico Hämäläinen on 30/03/15.
//  Copyright (c) 2015 Solinor Oy. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift

// MARK: Card Types

public struct ClutchDomains {
    static let Default = "fi.solinor.clutch.errordomain"
}

/// The recognized card types in the system
public enum SPHCardType: Int, CustomStringConvertible {
	case visa = 0
	case masterCard
	case americanExpress
	case discover
	case jcb
	case dinersClub
	case unsupported
	case invalid
	
	/// The valid card types
	static func validValues() -> [SPHCardType] {
		return [.visa, .masterCard, .americanExpress, .discover, .jcb, .dinersClub]
	}
	
	/// The invalid card types
	static func invalidValues() -> [SPHCardType] {
		return [.unsupported, .invalid]
	}

	/// Returns the correct NSPredicate for validating a card type
	static func matcherPredicateForType(_ cardType: SPHCardType) -> NSPredicate {
		var regexp: String? = nil
		switch cardType {
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
		default:
			regexp = nil
		}
		
		if let regexp = regexp {
			return NSPredicate(format: "SELF MATCHES %@", regexp)
		}
		else {
			return NSPredicate(value: false)
		}
	}
	
	/// Printable
	public var description: String {
		switch self {
		case .visa: return "Visa"
		case .masterCard: return "MasterCard"
		case .americanExpress: return "AmericanExpress"
		case .discover: return "Discover"
		case .jcb: return "JCB"
		case .dinersClub: return "DinersClub"
		case .invalid: return "Invalid"
		case .unsupported: return "Unsupported"
		}
	}
}

// MARK: Main Class

/// Main Clutch Class
open class SPH {
    
	/// The singleton accessor
	open class var sharedInstance: SPH {
        struct Static {
            static let instance: SPH = SPH()
        }
        
        return Static.instance
	}
    
    fileprivate var lastExpirationDateLength = 0
    
    internal var networking: Networking?
	
	// MARK: Initializers
	
	public init() { /* Nothing to do here */ }
	
    open class func initSharedInstance(merchantId: String, accountId: String, mobileApiAddress: String) {
        SPH.sharedInstance.networking = Networking(merchantId: merchantId, accountId: accountId, serviceUrl: mobileApiAddress)
	}

	// MARK: Card Recognition and Validation
	
	/// Formats a card number for processing purposes
    ///
	/// - parameter   cardNumber: The card number to format
	/// - returns: The formatted card number, or an empty string
	open func formattedCardNumberForProcessing(_ cardNumber: String) -> String {
		let illegal    = CharacterSet.decimalDigits.inverted
		let components = cardNumber.components(separatedBy: illegal)
		return components.joined(separator: "")
	}
	
	/// Recognize the type of a credit card number
    ///
	/// - parameter cardNumber: The card number string
	open func cardTypeForCardNumber(_ cardNumber: String) -> SPHCardType {
		let valid = self.isValidCardNumber(cardNumber)
		if !valid {
			return .invalid
		}
		
		let formattedString: String = self.formattedCardNumberForProcessing(cardNumber)
		if formattedString.characters.count < 9 {
			return .invalid
		}
		
		var foundType: SPHCardType = .invalid
		for type in SPHCardType.validValues() {
			let predicate = SPHCardType.matcherPredicateForType(type)
			if predicate.evaluate(with: cardNumber) == true {
				foundType = type
				break
			}
		}
		
		return foundType
	}
	
	/// Validate a given credit card number using the Luhn algorithm
    ///
	/// - parameter   cardNumber: The card number to validate
	/// - returns: true if the number passes, false if not
	open func isValidCardNumber(_ cardNumber: String) -> Bool {
		let formattedString = self.formattedCardNumberForProcessing(cardNumber)
		if formattedString.characters.count < 9 {
			return false
		}
        
		let asciiOffset: UInt8 = 48
		let digits = Array(Array(formattedString.utf8).reversed()).map{$0 - asciiOffset}
		
		let convert: (UInt8) -> (UInt8) = {
			let n = $0 * 2
			return n > 9 ? n - 9 : n
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
	/// - parameter   cardType:   The type of the card number
	/// - returns: The properly spaced credit card number
	open func formattedCardNumber(_ cardNumber: String, cardType: SPHCardType) -> String {
        let formattedString = self.formattedCardNumberForProcessing(cardNumber).truncate(19, trailing: "")
        
		// Stupid AMEX uses their own weird format
		var regexpString = "(\\d{1,4})"
		if cardType == .americanExpress {
			regexpString = "(\\d{1,4})(\\d{1,6})?(\\d{1,5})?"
		}
		
		// Create and check regexp matches
		// let regexp  = try! NSRegularExpression(pattern: regexpString, options: [])
		// var groups  = [String]()
        
        let matches = formattedString.matchesForRegex(regexpString)
		
		// Glue them together
		return matches.joined(separator: " ")
	}
    
    // MARK: expiration date 
    
    open func isValidExpirationDate(_ expirationDate: String) -> Bool {
        
        if(expirationDate.characters.count == 5)
        {
            let month = expirationDate.components(separatedBy: "/")[0]
            let year = "20" + expirationDate.components(separatedBy: "/")[1]
         
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMyyyy"
            
            let currentDate = dateFormatter.string(from: Date())
                        
            if let givenDate = dateFormatter.date(from: month + year) {
                if givenDate.compare(dateFormatter.date(from: currentDate)! ) != ComparisonResult.orderedAscending { //TODO: there might more easier way to do this..
                    return true
                }
            }
        }
        
        return false
    }
    
    open func formattedExpirationDateForProcessing(_ expirationDate: String) -> String {
        return formattedCardNumberForProcessing(expirationDate)
    }
    
    open func formattedExpirationDate(_ expirationDate: String) -> String {
        var onlyDigitsExpirationDate = formattedExpirationDateForProcessing(expirationDate)
        let length = onlyDigitsExpirationDate.characters.count
        
        var text = ""
        
        switch length {
        case 1:
            if(2...9 ~= Int(onlyDigitsExpirationDate)!)
            {
                text = "0\(onlyDigitsExpirationDate)/"
            } else {
                text = onlyDigitsExpirationDate
            }
        case 2:
            if (lastExpirationDateLength == 3)
            {
                text = onlyDigitsExpirationDate
            } else {
                if Int(onlyDigitsExpirationDate)! < 1 || Int(onlyDigitsExpirationDate)! > 12
                {
                    onlyDigitsExpirationDate.remove(at: onlyDigitsExpirationDate.characters.index(before: onlyDigitsExpirationDate.endIndex))
                    text = onlyDigitsExpirationDate
                } else {
                    text = "\(onlyDigitsExpirationDate)/"
                }
            }
        case 3:
            onlyDigitsExpirationDate.insert("/", at: onlyDigitsExpirationDate.characters.index(onlyDigitsExpirationDate.startIndex, offsetBy: 2))
            text = onlyDigitsExpirationDate
        case 4:
            onlyDigitsExpirationDate.insert("/", at: onlyDigitsExpirationDate.characters.index(onlyDigitsExpirationDate.startIndex, offsetBy: 2))
            text = onlyDigitsExpirationDate
        case 5:
            onlyDigitsExpirationDate.remove(at: onlyDigitsExpirationDate.characters.index(before: onlyDigitsExpirationDate.endIndex))
            onlyDigitsExpirationDate.insert("/", at: onlyDigitsExpirationDate.characters.index(onlyDigitsExpirationDate.startIndex, offsetBy: 2))
            text = onlyDigitsExpirationDate
        default:
            text = ""
        }
        
        lastExpirationDateLength = text.characters.count
        
        return text
    }
    
    open func isValidSecurityCode(_ securityCode: String) -> Bool {
        return self.formattedSecurityCodeForProcessing(securityCode).characters.count > 0
    }
    
    open func formattedSecurityCodeForProcessing(_ securityCode: String) -> String {
        return formattedCardNumberForProcessing(securityCode)
    }
    
    open func formattedSecurityCode(_ securityCode: String) -> String {
        var onlyDigitsSecurityCode = formattedSecurityCodeForProcessing(securityCode)
        var text = ""
        switch onlyDigitsSecurityCode.characters.count
        {
            case 0...4 : text = onlyDigitsSecurityCode
            case 5 :
                onlyDigitsSecurityCode.remove(at: onlyDigitsSecurityCode.characters.index(before: onlyDigitsSecurityCode.endIndex))
                text = onlyDigitsSecurityCode
            default : text = ""
        }
        return text
    }
    
    open func transactionId(hostname: String, success: @escaping (String) -> (), failure: @escaping (Error) -> ()) -> () {
        networking!.transactionId(hostname: hostname, success: success, failure: failure)
    }
    
    open func transactionToken(hostname: String, transactionId: String, success: @escaping (String) -> (), failure: @escaping (Error) -> ()) -> () {
        networking!.transactionToken(hostname: hostname, transactionId: transactionId, success: success, failure: failure)
    }
    
    open func addCard(_ transactionId: String, pan: String, cvc: String, expiryMonth: String, expiryYear: String, success: @escaping (String) -> (), failure: @escaping (NSError) -> ()) -> () {
        
        func handleReceivedTokenisationResult(_ result: String) -> () {
            success(result)
        }
        
        func handleFailure(_ error: NSError) -> () {
            print("Failed to receive key")
            failure(error)
        }
        
        func handleReceivedKeySuccess(_ key: String) -> () {
            print("Received key \(key)")
            networking!.tokenizeTransaction(transactionId: transactionId, expiryMonth: expiryMonth, expiryYear: expiryYear, cvc: cvc, pan: pan, certificateBase64Der: key, success: {success($0)}, failure: {failure($0 as NSError)})
        }
        
        networking!.transactionKey(transactionId: transactionId, success: handleReceivedKeySuccess, failure: { error in
            print("Failed to get response: \(error)")
        })
        
        }
    }

